# frozen_string_literal: true

module Api
    module V1
        class SectionsController < BaseController
            def index
                scope = policy_scope(Section).kept
                scope = scope.where(school_class_id: params[:class_id]) if params[:class_id]
                @sections = paginate(scope.order(:name))
                render :index
            end

            def show
                @section = policy_scope(Section).kept.find(params.expect(:id))
                authorize @section
                render :show
            end

            def create
                school_class = policy_scope(SchoolClass).kept.find(section_params[:school_class_id])
                @section = school_class.sections.new(section_params.except(:school_class_id))
                authorize @section

                if @section.save
                    render :show, status: :created
                else
                    render_validation_errors(@section.errors)
                end
            end

            def update
                @section = policy_scope(Section).kept.find(params.expect(:id))
                authorize @section

                if @section.update(section_params.except(:school_class_id))
                    render :show
                else
                    render_validation_errors(@section.errors)
                end
            end

            def destroy
                @section = policy_scope(Section).kept.find(params.expect(:id))
                authorize @section
                @section.discard
                head :no_content
            end

            private

            def section_params
                params.expect(section: %i[school_class_id name capacity homeroom_teacher_id])
            end
        end
    end
end
