# frozen_string_literal: true

module Api
    module V1
        class SubjectsController < BaseController
            def index
                scope = policy_scope(Subject).kept
                scope = scope.where(department_id: params[:department_id]) if params[:department_id]
                @subjects = paginate(scope.order(:name))
                render :index
            end

            def show
                @subject = policy_scope(Subject).kept.find(params.expect(:id))
                authorize @subject
                render :show
            end

            def create
                @subject = Subject.new(subject_params)
                authorize @subject

                if @subject.save
                    render :show, status: :created
                else
                    render_validation_errors(@subject.errors)
                end
            end

            def update
                @subject = policy_scope(Subject).kept.find(params.expect(:id))
                authorize @subject

                if @subject.update(subject_params)
                    render :show
                else
                    render_validation_errors(@subject.errors)
                end
            end

            def destroy
                @subject = policy_scope(Subject).kept.find(params.expect(:id))
                authorize @subject
                @subject.discard
                head :no_content
            end

            private

            def subject_params
                params.expect(subject: %i[name code department_id])
            end
        end
    end
end
