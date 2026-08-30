# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
    def index?
        admin? || teacher? || student? || parent?
    end

    def show?
        return false unless same_school?

        admin? || assigned_teacher? || self_record? || parent_of?
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

    def enroll?
        admin? && same_school?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin"
                tenant_scope
            when "teacher"
                teacher = Teacher.find_by(user_id: user.id)
                teacher ? tenant_scope.in_teacher_sections(teacher) : scope.none
            when "student"
                tenant_scope.where(user_id: user.id)
            when "parent"
                parent = Parent.find_by(user_id: user.id)
                if parent
                    tenant_scope.joins(:parent_students).where(parent_students: { parent_id: parent.id })
                else
                    scope.none
                end
            else
                scope.none
            end
        end
    end

    private

    def self_record?
        record.user_id == user.id
    end

    def assigned_teacher?
        return false unless teacher?

        teacher = Teacher.find_by(user_id: user.id)
        return false if teacher.nil?

        Student.in_teacher_sections(teacher).exists?(record.id)
    end

    def parent_of?
        return false unless parent?

        parent = Parent.find_by(user_id: user.id)
        return false if parent.nil?

        ParentStudent.exists?(parent_id: parent.id, student_id: record.id)
    end
end
