# frozen_string_literal: true

# Read for every authenticated school member; write is admin-only.
class AcademicYearPolicy < ApplicationPolicy
    def index?
        true
    end

    def show?
        same_school?
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
            tenant_scope
        end
    end
end
