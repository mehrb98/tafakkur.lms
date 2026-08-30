# frozen_string_literal: true

# Applies tenant isolation to a model. Every tenant-owned model includes this
# concern; queries are automatically scoped to Current.school when set, and
# school_id is assigned on create as a safety net. Pundit policy scopes remain
# the primary isolation mechanism — this default scope is defense in depth.
module TenantScoped
    extend ActiveSupport::Concern

    included do
        belongs_to :school

        default_scope do
            Current.school ? where(school_id: Current.school.id) : all
        end

        before_validation :assign_current_school, on: :create
    end

    private

    def assign_current_school
        self.school_id ||= Current.school&.id
    end
end
