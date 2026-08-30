# frozen_string_literal: true

class GradePolicy < ApplicationPolicy
    def index?
        true
    end

    def show?
        return false unless same_school?

        admin? || own_subject_grade? || self_grade? || parent_of_grade?
    end

    def create?
        admin? || teaches_subject?
    end

    def update?
        return false unless same_school?

        admin? || own_subject_grade?
    end

    def destroy?
        admin? && same_school?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin"
                tenant_scope
            when "teacher"
                teacher = Teacher.find_by(user_id: user.id)
                teacher ? tenant_scope.where(teacher_id: teacher.id) : scope.none
            when "student"
                student = Student.find_by(user_id: user.id)
                student ? tenant_scope.where(student_id: student.id) : scope.none
            when "parent"
                parent = Parent.find_by(user_id: user.id)
                return scope.none if parent.nil?

                tenant_scope.where(student_id: parent.parent_students.select(:student_id))
            else
                scope.none
            end
        end
    end

    private

    def teacher_profile
        return @teacher_profile if defined?(@teacher_profile)

        @teacher_profile = Teacher.find_by(user_id: user.id)
    end

    # The grade being created/updated belongs to this teacher.
    def own_subject_grade?
        teacher? && teacher_profile && record.teacher_id == teacher_profile.id
    end

    # For create: the teacher must be assigned to the grade's subject for the
    # grade's semester.
    def teaches_subject?
        return false unless teacher? && teacher_profile

        SubjectAssignment.exists?(
            teacher_id: teacher_profile.id,
            subject_id: record.subject_id,
            semester_id: record.semester_id
        )
    end

    def self_grade?
        student? && Student.find_by(user_id: user.id)&.id == record.student_id
    end

    def parent_of_grade?
        return false unless parent?

        parent = Parent.find_by(user_id: user.id)
        parent && ParentStudent.exists?(parent_id: parent.id, student_id: record.student_id)
    end
end
