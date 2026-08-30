# frozen_string_literal: true

module Api
    module V1
        class AcademicYearsController < BaseController
            def index
                @academic_years = paginate(
                    policy_scope(AcademicYear).kept.order(start_date: :desc)
                )
                render :index
            end

            def show
                @academic_year = policy_scope(AcademicYear).kept.find(params.expect(:id))
                authorize @academic_year
                render :show
            end

            def create
                @academic_year = AcademicYear.new(academic_year_params)
                authorize @academic_year

                if @academic_year.save
                    set_current! if params.dig(:academic_year, :is_current)
                    AuditLog.record!(user: current_user, action: "academic_year_created", auditable: @academic_year)
                    render :show, status: :created
                else
                    render_validation_errors(@academic_year.errors)
                end
            end

            def update
                @academic_year = policy_scope(AcademicYear).kept.find(params.expect(:id))
                authorize @academic_year

                if @academic_year.update(academic_year_params)
                    set_current! if params.dig(:academic_year, :is_current)
                    render :show
                else
                    render_validation_errors(@academic_year.errors)
                end
            end

            def destroy
                @academic_year = policy_scope(AcademicYear).kept.find(params.expect(:id))
                authorize @academic_year
                @academic_year.discard
                head :no_content
            end

            private

            def set_current!
                AcademicYears::SetCurrent.call(academic_year: @academic_year)
                @academic_year.reload
            end

            def academic_year_params
                params.expect(academic_year: %i[name start_date end_date])
            end
        end
    end
end
