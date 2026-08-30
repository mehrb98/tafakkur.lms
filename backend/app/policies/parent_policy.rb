# frozen_string_literal: true

class ParentPolicy < ApplicationPolicy
    def index?
        admin?
    end

    def show?
        return false unless same_school?

        admin? || self_record?
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

    def link_student?
        admin? && same_school?
    end

    def children?
        (admin? || self_record?) && same_school?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin" then tenant_scope
            when "parent" then tenant_scope.where(user_id: user.id)
            else scope.none
            end
        end
    end

    private

    def self_record?
        record.user_id == user.id
    end
end
