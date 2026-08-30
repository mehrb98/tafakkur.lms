# frozen_string_literal: true

module Api
    module V1
        class TeachersController < BaseController
            def index
                scope = policy_scope(Teacher).kept.includes(:user, :department)
                scope = scope.search(params[:q]) if params[:q].present?
                @teachers = paginate(scope.order(:employee_code))
                render :index
            end

            def show
                @teacher = policy_scope(Teacher).kept.find(params.expect(:id))
                authorize @teacher
                render :show
            end

            def create
                authorize Teacher

                result = Teachers::Create.call(
                    user_attributes: user_params.to_h,
                    role: "teacher",
                    profile_attributes: teacher_params.to_h
                )
                return render_interactor_error(result) if result.failure?

                @teacher = result.teacher
                render :show, status: :created
            end

            def update
                @teacher = policy_scope(Teacher).kept.find(params.expect(:id))
                authorize @teacher

                if @teacher.update(teacher_params)
                    render :show
                else
                    render_validation_errors(@teacher.errors)
                end
            end

            def destroy
                @teacher = policy_scope(Teacher).kept.find(params.expect(:id))
                authorize @teacher
                ActiveRecord::Base.transaction do
                    @teacher.discard
                    @teacher.user.discard
                end
                head :no_content
            end

            private

            def user_params
                params.require(:teacher).require(:user)
                      .permit(:email, :first_name, :last_name, :phone, :password)
            end

            def teacher_params
                params
                    .expect(teacher: %i[employee_code specialization hire_date department_id])
            end
        end
    end
end
