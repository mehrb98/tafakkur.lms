# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendWelcomeEmailJob, type: :job do
    it "delivers the welcome email" do
        user = create(:user)

        expect { described_class.perform_now(user.id) }
            .to change(ActionMailer::Base.deliveries, :count).by(1)

        expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
    end

    it "skips undeliverable users" do
        user = create(:user, email_deliverable: false)

        expect { described_class.perform_now(user.id) }
            .not_to change(ActionMailer::Base.deliveries, :count)
    end
end
