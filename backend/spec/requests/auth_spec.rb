# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :request do
    let(:school) { create(:school) }
    let(:password) { "SecurePassword123" }
    let!(:user) { create(:user, :admin, school: school, password: password) }

    def login(remember_me: false)
        post "/api/v1/auth/login",
             params: { email: user.email, password: password, remember_me: remember_me }.to_json,
             headers: { "Content-Type" => "application/json" }
    end

    describe "POST /api/v1/auth/login" do
        it "returns access token, user payload and sets refresh cookie" do
            login

            expect(response).to have_http_status(:created)
            expect(json_body.dig("data", "access_token")).to be_present
            expect(json_body.dig("data", "expires_in")).to eq(900)
            expect(json_body.dig("data", "user", "role")).to eq("admin")
            expect(response.cookies["refresh_token"]).to be_present
        end

        it "creates a device session and audit log" do
            expect { login }.to change(DeviceSession, :count).by(1)
                                                             .and change(AuditLog.where(action: "login"), :count).by(1)
        end

        it "rejects invalid credentials with 401" do
            post "/api/v1/auth/login",
                 params: { email: user.email, password: "wrong-password" }.to_json,
                 headers: { "Content-Type" => "application/json" }

            expect(response).to have_http_status(:unauthorized)
            expect(json_body.dig("error", "code")).to eq("unauthorized")
        end

        it "rejects discarded users" do
            user.discard
            login
            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe "POST /api/v1/auth/refresh" do
        it "rotates the refresh token and returns a new access token" do
            login
            old_cookie = response.cookies["refresh_token"]

            post "/api/v1/auth/refresh"

            expect(response).to have_http_status(:ok)
            expect(json_body.dig("data", "access_token")).to be_present
            expect(response.cookies["refresh_token"]).to be_present
            expect(response.cookies["refresh_token"]).not_to eq(old_cookie)
        end

        it "revokes all sessions when a revoked token is reused" do
            login
            stolen_cookie = response.cookies["refresh_token"]

            post "/api/v1/auth/refresh" # legitimate rotation revokes stolen_cookie

            # Attacker replays the old token
            cookies_jar = ActionDispatch::Request.new(request.env).cookie_jar
            cookies_jar[:refresh_token] = stolen_cookie
            post "/api/v1/auth/refresh", headers: { "Cookie" => "refresh_token=#{stolen_cookie}" }

            expect(response).to have_http_status(:unauthorized)
            expect(user.refresh_tokens.active).to be_empty
            expect(AuditLog.where(action: "refresh_token_reuse_detected")).to exist
        end

        it "returns 401 without a refresh cookie" do
            post "/api/v1/auth/refresh"
            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe "POST /api/v1/auth/logout" do
        it "revokes the current refresh token" do
            login
            access_token = json_body.dig("data", "access_token")

            post "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:no_content)
            expect(user.refresh_tokens.active).to be_empty
        end

        it "denylists the access token" do
            login
            access_token = json_body.dig("data", "access_token")

            post "/api/v1/auth/logout", headers: { "Authorization" => "Bearer #{access_token}" }
            get "/api/v1/school", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:unauthorized)
        end
    end

    describe "DELETE /api/v1/auth/sessions (logout all)" do
        it "revokes every refresh token for the user" do
            login
            login
            access_token = json_body.dig("data", "access_token")
            expect(user.refresh_tokens.active.count).to eq(2)

            delete "/api/v1/auth/sessions", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:no_content)
            expect(user.refresh_tokens.active).to be_empty
        end
    end

    describe "GET /api/v1/auth/sessions" do
        it "lists active device sessions" do
            login
            access_token = json_body.dig("data", "access_token")

            get "/api/v1/auth/sessions", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:ok)
            expect(json_body["data"].length).to eq(1)
            expect(json_body["data"].first).to include("device_name", "last_active_at")
        end
    end

    describe "POST /api/v1/auth/password" do
        it "always returns 200 and enqueues reset job for known email" do
            expect do
                post "/api/v1/auth/password",
                     params: { email: user.email }.to_json,
                     headers: { "Content-Type" => "application/json" }
            end.to have_enqueued_job(SendPasswordResetJob)

            expect(response).to have_http_status(:ok)
        end

        it "returns 200 without enqueuing for unknown email" do
            expect do
                post "/api/v1/auth/password",
                     params: { email: "nobody@example.com" }.to_json,
                     headers: { "Content-Type" => "application/json" }
            end.not_to have_enqueued_job(SendPasswordResetJob)

            expect(response).to have_http_status(:ok)
        end
    end

    describe "PATCH /api/v1/auth/password" do
        it "resets the password with a valid token and revokes sessions" do
            login
            raw_token = user.send(:set_reset_password_token)

            patch "/api/v1/auth/password",
                  params: {
                      token: raw_token,
                      password: "BrandNewPassword99",
                      password_confirmation: "BrandNewPassword99"
                  }.to_json,
                  headers: { "Content-Type" => "application/json" }

            expect(response).to have_http_status(:ok)
            expect(user.reload.valid_password?("BrandNewPassword99")).to be(true)
            expect(user.refresh_tokens.active).to be_empty
        end

        it "rejects an invalid token" do
            patch "/api/v1/auth/password",
                  params: { token: "bogus", password: "BrandNewPassword99" }.to_json,
                  headers: { "Content-Type" => "application/json" }

            expect(response).to have_http_status(:unprocessable_entity)
        end
    end

    describe "GET /api/v1/auth/confirmation" do
        it "confirms email with a valid token" do
            unconfirmed = create(:user, :unconfirmed, school: school)
            raw = unconfirmed.confirmation_token

            get "/api/v1/auth/confirmation", params: { token: raw }

            expect(response).to have_http_status(:ok)
            expect(unconfirmed.reload.email_verified?).to be(true)
        end
    end
end
