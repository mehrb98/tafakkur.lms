# frozen_string_literal: true

class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
        @user = user
        @record = record
    end

    def index?
        false
    end

    def show?
        false
    end

    def create?
        false
    end

    def update?
        false
    end

    def destroy?
        false
    end

    class Scope
        attr_reader :user, :scope

        def initialize(user, scope)
            @user = user
            @scope = scope
        end

        def resolve
            scope.none
        end

        private

        # Every scope starts from the tenant boundary. Never resolve records
        # outside the authenticated user's school.
        def tenant_scope
            scope.where(school_id: user.school_id)
        end
    end

    private

    def admin?
        user.admin?
    end

    def teacher?
        user.teacher?
    end

    def student?
        user.student?
    end

    def parent?
        user.parent?
    end

    def same_school?
        record.respond_to?(:school_id) && record.school_id == user.school_id
    end
end
