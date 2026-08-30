# frozen_string_literal: true

module Api
    module V1
        class StudentsController < BaseController
            def index
                scope = policy_scope(Student).kept.includes(:user)
                scope = scope.search(params[:q]) if params[:q].present?
                @students = paginate(scope.order(:student_code))
                render :index
            end

            def show
                @student = policy_scope(Student).kept.find(params.expect(:id))
                authorize @student
                render :show
            end

            def create
                authorize Student

                result = Students::Create.call(
                    user_attributes: user_params.to_h,
                    role: "student",
                    profile_attributes: student_params.to_h
                )
                return render_interactor_error(result) if result.failure?

                @student = result.student
                render :show, status: :created
            end

            def update
                @student = policy_scope(Student).kept.find(params.expect(:id))
                authorize @student

                if @student.update(student_params)
                    render :show
                else
                    render_validation_errors(@student.errors)
                end
            end

            def destroy
                @student = policy_scope(Student).kept.find(params.expect(:id))
                authorize @student
                ActiveRecord::Base.transaction do
                    @student.discard
                    @student.user.discard
                end
                head :no_content
            end

            def enroll
                @student = policy_scope(Student).kept.find(params.expect(:id))
                authorize @student, :enroll?

                result = Organizers::EnrollStudent.call(
                    student: @student,
                    section_id: params.require(:section_id),
                    enrolled_on: params[:enrolled_on]
                )
                return render_interactor_error(result) if result.failure?

                @enrollment = result.enrollment
                render :enroll, status: :created
            end

            private

            def user_params
                params.require(:student).require(:user)
                      .permit(:email, :first_name, :last_name, :phone, :password)
            end

            def student_params
                params
                    .expect(student: %i[student_code date_of_birth gender address admission_date])
            end
        end
    end
end
