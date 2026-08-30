# frozen_string_literal: true

# Shared example enforcing the SAD rule: cross-tenant access must return 404
# (not 403) so record existence is never leaked across schools.
#
# Usage:
#   it_behaves_like "tenant isolated", :get do
#       let(:other_record_path) { "/api/v1/students/#{other_school_student.id}" }
#       let(:requesting_user) { admin }
#   end
RSpec.shared_examples "tenant isolated" do |http_method|
    it "returns 404 for records belonging to another school" do
        send(http_method, other_record_path,
             headers: authenticated_headers(requesting_user),
             params: defined?(other_record_params) ? other_record_params.to_json : nil)

        expect(response).to have_http_status(:not_found)
        expect(json_body.dig("error", "code")).to eq("not_found")
    end
end
