# frozen_string_literal: true

module Api
    module V1
        class SemestersController < BaseController
            def index
                scope = policy_scope(Semester).kept
                scope = scope.where(academic_year_id: params[:academic_year_id]) if params[:academic_year_id]
                @semesters = paginate(scope.order(start_date: :asc))
                render :index
            end

            def show
                @semester = policy_scope(Semester).kept.find(params.expect(:id))
                authorize @semester
                render :show
            end

            def create
                academic_year = policy_scope(AcademicYear).kept.find(semester_params[:academic_year_id])
                @semester = academic_year.semesters.new(semester_params.except(:academic_year_id))
                authorize @semester

                if @semester.save
                    render :show, status: :created
                else
                    render_validation_errors(@semester.errors)
                end
            end

            def update
                @semester = policy_scope(Semester).kept.find(params.expect(:id))
                authorize @semester

                if @semester.update(semester_params.except(:academic_year_id))
                    render :show
                else
                    render_validation_errors(@semester.errors)
                end
            end

            def destroy
                @semester = policy_scope(Semester).kept.find(params.expect(:id))
                authorize @semester
                @semester.discard
                head :no_content
            end

            private

            def semester_params
                params.expect(semester: %i[academic_year_id name start_date end_date])
            end
        end
    end
end
