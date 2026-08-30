# frozen_string_literal: true

module Api
    module V1
        class DepartmentsController < BaseController
            def index
                @departments = paginate(policy_scope(Department).kept.order(:name))
                render :index
            end

            def show
                @department = policy_scope(Department).kept.find(params.expect(:id))
                authorize @department
                render :show
            end

            def create
                @department = Department.new(department_params)
                authorize @department

                if @department.save
                    render :show, status: :created
                else
                    render_validation_errors(@department.errors)
                end
            end

            def update
                @department = policy_scope(Department).kept.find(params.expect(:id))
                authorize @department

                if @department.update(department_params)
                    render :show
                else
                    render_validation_errors(@department.errors)
                end
            end

            def destroy
                @department = policy_scope(Department).kept.find(params.expect(:id))
                authorize @department
                @department.discard
                head :no_content
            end

            private

            def department_params
                params.expect(department: %i[name description parent_id])
            end
        end
    end
end
