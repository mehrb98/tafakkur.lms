# frozen_string_literal: true

module Api
    module V1
        class SettingsController < BaseController
            def show
                authorize current_school, :manage_settings?
                render json: { data: current_school.settings }
            end

            def update
                authorize current_school, :manage_settings?

                merged = current_school.settings.deep_merge(settings_params)

                if current_school.update(settings: merged)
                    AuditLog.record!(user: current_user, action: "settings_updated", auditable: current_school)
                    render json: { data: current_school.settings }
                else
                    render_validation_errors(current_school.errors)
                end
            end

            private

            def settings_params
                params.expect(
                    settings: [{ branding: %i[logo_url primary_color],
                                 features: %i[messaging analytics attendance_notifications grade_notifications],
                                 limits: %i[max_file_size_mb max_students] }]
                ).to_h
            end
        end
    end
end
