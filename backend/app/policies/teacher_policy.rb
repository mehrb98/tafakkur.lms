# frozen_string_literal: true

class TeacherPolicy < ApplicationPolicy
    def index?
        admin? || teacher?
    end

    def show?
        return false unless same_school?

        admin? || teacher?
    end

    def create?
        admin?
    end

    def update?
        admin? && same_school?
    end

    def destroy?
        admin? && same_school?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin" then tenant_scope
            when "teacher" then tenant_scope
            else scope.none
            end
        end
    end
end
