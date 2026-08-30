# frozen_string_literal: true

module Api
    module V1
        class SchoolClassesController < BaseController
            def index
                scope = policy_scope(SchoolClass).kept
                scope = scope.where(academic_year_id: params[:academic_year_id]) if params[:academic_year_id]
                @school_classes = paginate(scope.order(:grade_level, :name))
                render :index
            end

            def show
                @school_class = policy_scope(SchoolClass).kept.find(params.expect(:id))
                authorize @school_class
                render :show
            end

            def create
                @school_class = SchoolClass.new(school_class_params)
                authorize @school_class

                if @school_class.save
                    render :show, status: :created
                else
                    render_validation_errors(@school_class.errors)
                end
            end

            def update
                @school_class = policy_scope(SchoolClass).kept.find(params.expect(:id))
                authorize @school_class

                if @school_class.update(school_class_params)
                    render :show
                else
                    render_validation_errors(@school_class.errors)
                end
            end

            def destroy
                @school_class = policy_scope(SchoolClass).kept.find(params.expect(:id))
                authorize @school_class
                @school_class.discard
                head :no_content
            end

            private

            def school_class_params
                params.expect(school_class: %i[name grade_level academic_year_id department_id])
            end
        end
    end
end
