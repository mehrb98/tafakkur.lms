# frozen_string_literal: true

module Api
    module V1
        class SchoolsController < BaseController
            def show
                @school = current_school
                authorize @school
                render :show
            end

            def update
                @school = current_school
                authorize @school

                if @school.update(school_params)
                    AuditLog.record!(user: current_user, action: "school_updated", auditable: @school)
                    render :show
                else
                    render_validation_errors(@school.errors)
                end
            end

            private

            def school_params
                params.expect(school: %i[name timezone locale])
            end
        end
    end
end
