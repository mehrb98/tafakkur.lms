# frozen_string_literal: true

require "rails_helper"

RSpec.describe "QR login", type: :request do
    let(:school) { create(:school) }
    let!(:phone_user) { create(:user, :admin, school: school) }
    let(:json_headers) { { "Content-Type" => "application/json" } }

    def create_qr
        post "/api/v1/auth/qr", headers: json_headers.merge("User-Agent" => "Mozilla/5.0 (Macintosh) Chrome/120.0")
        json_body["data"]
    end

    def poll(poll_secret)
        post "/api/v1/auth/qr/poll", params: { poll_secret: poll_secret }.to_json, headers: json_headers
    end

    def phone(action, qr_token, user: phone_user)
        post "/api/v1/auth/qr/#{action}", params: { qr_token: qr_token }.to_json, headers: authenticated_headers(user)
    end

    describe "POST /api/v1/auth/qr" do
        it "returns a QR token and a separate poll secret, storing only digests" do
            data = create_qr

            expect(response).to have_http_status(:created)
            expect(data["qr_token"]).to be_present
            expect(data["poll_secret"]).to be_present
            expect(data["qr_token"]).not_to eq(data["poll_secret"])
            expect(data["expires_in"]).to eq(120)

            record = QrLoginRequest.last
            expect(record.token_digest).to eq(QrLoginRequest.digest(data["qr_token"]))
            expect(record.token_digest).not_to include(data["qr_token"])
            expect(record.status).to eq("pending")
        end
    end

    describe "full flow" do
        it "logs the browser in as the phone's user after scan and approve" do
            qr = create_qr

            poll(qr["poll_secret"])
            expect(json_body.dig("data", "status")).to eq("pending")

            phone("scan", qr["qr_token"])
            expect(response).to have_http_status(:ok)
            expect(json_body.dig("data", "device_name")).to be_present

            poll(qr["poll_secret"])
            expect(json_body.dig("data", "status")).to eq("scanned")

            phone("approve", qr["qr_token"])
            expect(response).to have_http_status(:ok)

            expect { poll(qr["poll_secret"]) }.to change(DeviceSession, :count).by(1)
            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "access_token")).to be_present
            expect(json_body.dig("data", "user", "id")).to eq(phone_user.id)
            expect(response.cookies["refresh_token"]).to be_present
            expect(AuditLog.where(action: "qr_login_approved", user: phone_user)).to exist
        end

        it "issues the session only once" do
            qr = create_qr
            phone("approve", qr["qr_token"])

            poll(qr["poll_secret"])
            expect(response).to have_http_status(:created)

            expect { poll(qr["poll_secret"]) }.not_to change(DeviceSession, :count)
            expect(json_body.dig("data", "status")).to eq("consumed")
        end
    end

    describe "security" do
        it "does not accept the QR token as a poll secret" do
            qr = create_qr
            phone("approve", qr["qr_token"])

            poll(qr["qr_token"])

            expect(response).to have_http_status(:not_found)
        end

        it "requires a signed-in phone to scan or approve" do
            qr = create_qr

            post "/api/v1/auth/qr/approve", params: { qr_token: qr["qr_token"] }.to_json, headers: json_headers

            expect(response).to have_http_status(:unauthorized)
            expect(QrLoginRequest.last.status).to eq("pending")
        end

        it "does not let a second user approve a code another user scanned" do
            qr = create_qr
            phone("scan", qr["qr_token"])
            other = create(:user, :admin, school: school)

            phone("approve", qr["qr_token"], user: other)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_body.dig("error", "code")).to eq("qr_login_unavailable")
        end

        it "rejects expired codes" do
            qr = create_qr
            QrLoginRequest.last.update!(expires_at: 1.second.ago)

            phone("approve", qr["qr_token"])
            expect(response).to have_http_status(:unprocessable_entity)

            poll(qr["poll_secret"])
            expect(json_body.dig("data", "status")).to eq("expired")
        end

        it "does not issue a session for a declined code" do
            qr = create_qr
            phone("decline", qr["qr_token"])

            expect { poll(qr["poll_secret"]) }.not_to change(DeviceSession, :count)
            expect(json_body.dig("data", "status")).to eq("declined")

            phone("approve", qr["qr_token"])
            expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns 404 for unknown tokens" do
            phone("scan", "not-a-real-token")
            expect(response).to have_http_status(:not_found)
        end
    end
end
