# frozen_string_literal: true

module Api
    module V1
        class ParentsController < BaseController
            def index
                @parents = paginate(policy_scope(Parent).kept.includes(:user).order(:created_at))
                render :index
            end

            def show
                @parent = policy_scope(Parent).kept.find(params.expect(:id))
                authorize @parent
                render :show
            end

            def create
                authorize Parent

                result = Parents::Create.call(
                    user_attributes: user_params.to_h,
                    role: "parent",
                    profile_attributes: parent_params.to_h
                )
                return render_interactor_error(result) if result.failure?

                @parent = result.parent
                render :show, status: :created
            end

            def update
                @parent = policy_scope(Parent).kept.find(params.expect(:id))
                authorize @parent

                if @parent.update(parent_params)
                    render :show
                else
                    render_validation_errors(@parent.errors)
                end
            end

            def destroy
                @parent = policy_scope(Parent).kept.find(params.expect(:id))
                authorize @parent
                ActiveRecord::Base.transaction do
                    @parent.discard
                    @parent.user.discard
                end
                head :no_content
            end

            def link_student
                @parent = policy_scope(Parent).kept.find(params.expect(:id))
                authorize @parent, :link_student?

                result = Parents::LinkStudent.call(
                    parent: @parent,
                    student_id: params.require(:student_id),
                    relationship: params.require(:relationship)
                )
                return render_interactor_error(result) if result.failure?

                @link = result.link
                render :link_student, status: :created
            end

            def children
                @parent = policy_scope(Parent).kept.find(params.expect(:id))
                authorize @parent, :children?
                @students = @parent.students.kept.includes(:user)
                render :children
            end

            private

            def user_params
                params.require(:parent).require(:user)
                      .permit(:email, :first_name, :last_name, :phone, :password)
            end

            def parent_params
                params.fetch(:parent, {}).permit(:occupation)
            end
        end
    end
end
