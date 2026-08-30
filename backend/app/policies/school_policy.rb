# frozen_string_literal: true

class SchoolPolicy < ApplicationPolicy
    def show?
        record.id == user.school_id
    end

    def update?
        admin? && record.id == user.school_id
    end

    def manage_settings?
        admin? && record.id == user.school_id
    end
end
