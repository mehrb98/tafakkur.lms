# frozen_string_literal: true

module Api
    module V1
        class GradesController < BaseController
            def index
                scope = policy_scope(Grade)
                scope = scope.where(student_id: params[:student_id]) if params[:student_id]
                scope = scope.where(subject_id: params[:subject_id]) if params[:subject_id]
                scope = scope.where(semester_id: params[:semester_id]) if params[:semester_id]
                scope = scope.where(grade_type: params[:grade_type]) if params[:grade_type]
                @grades = paginate(scope.order(graded_on: :desc))
                render :index
            end

            def show
                @grade = policy_scope(Grade).find(params.expect(:id))
                authorize @grade
                render :show
            end

            def create
                grade_teacher = resolve_teacher
                @grade = Grade.new(grade_params.merge(teacher: grade_teacher))
                authorize @grade

                result = Grades::Create.call(attributes: grade_params.to_h, teacher: grade_teacher)
                return render_interactor_error(result) if result.failure?

                @grade = result.grade
                render :show, status: :created
            end

            def update
                @grade = policy_scope(Grade).find(params.expect(:id))
                authorize @grade

                result = Grades::Update.call(grade: @grade, attributes: update_params.to_h)
                return render_interactor_error(result) if result.failure?

                render :show
            end

            def destroy
                @grade = policy_scope(Grade).find(params.expect(:id))
                authorize @grade
                @grade.destroy
                AuditLog.record!(user: current_user, action: "grade_deleted", auditable: @grade)
                head :no_content
            end

            private

            # Teachers grade as themselves; admins must specify the teacher.
            def resolve_teacher
                if current_user.teacher?
                    Teacher.kept.find_by!(user_id: current_user.id)
                else
                    Teacher.kept.find(params.require(:grade).require(:teacher_id))
                end
            end

            def grade_params
                params
                    .expect(grade: %i[student_id subject_id semester_id grade_type
                                      value max_value comment graded_on])
            end

            def update_params
                params.expect(grade: %i[value max_value comment grade_type graded_on])
            end
        end
    end
end
