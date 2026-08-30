# frozen_string_literal: true

module Api
    module V1
        class SubjectAssignmentsController < BaseController
            def index
                scope = policy_scope(SubjectAssignment)
                scope = scope.where(teacher_id: params[:teacher_id]) if params[:teacher_id]
                scope = scope.where(section_id: params[:section_id]) if params[:section_id]
                @subject_assignments = paginate(scope.order(created_at: :desc))
                render :index
            end

            def create
                @subject_assignment = SubjectAssignment.new(subject_assignment_params)
                authorize @subject_assignment

                if @subject_assignment.save
                    render :show, status: :created
                else
                    render_validation_errors(@subject_assignment.errors)
                end
            end

            def destroy
                @subject_assignment = policy_scope(SubjectAssignment).find(params.expect(:id))
                authorize @subject_assignment
                @subject_assignment.destroy
                head :no_content
            end

            private

            def subject_assignment_params
                params.expect(subject_assignment: %i[teacher_id subject_id section_id semester_id])
            end
        end
    end
end
