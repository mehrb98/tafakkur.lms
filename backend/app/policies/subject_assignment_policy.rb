# frozen_string_literal: true

class SubjectAssignmentPolicy < ApplicationPolicy
    def index?
        admin? || teacher?
    end

    def create?
        admin?
    end

    def destroy?
        admin? && same_school?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin" then tenant_scope
            when "teacher"
                teacher = Teacher.find_by(user_id: user.id)
                teacher ? tenant_scope.where(teacher_id: teacher.id) : scope.none
            else scope.none
            end
        end
    end
end
