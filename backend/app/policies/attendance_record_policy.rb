# frozen_string_literal: true

class AttendanceRecordPolicy < ApplicationPolicy
    def index?
        true
    end

    # record is the Section being recorded against.
    def bulk?
        return false unless record.school_id == user.school_id

        admin? || records_own_section?
    end

    def update?
        return false unless same_school?

        admin? || records_own_section?
    end

    class Scope < Scope
        def resolve
            case user.role
            when "admin"
                tenant_scope
            when "teacher"
                teacher = Teacher.find_by(user_id: user.id)
                return scope.none if teacher.nil?

                section_ids = SubjectAssignment.where(teacher_id: teacher.id).pluck(:section_id) |
                              Section.where(homeroom_teacher_id: teacher.id).pluck(:id)
                tenant_scope.where(section_id: section_ids)
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

    # Teachers may record/update attendance only for sections they teach or
    # homeroom.
    def records_own_section?
        return false unless teacher?

        teacher = Teacher.find_by(user_id: user.id)
        return false if teacher.nil?

        section = record.is_a?(Section) ? record : record.section
        SubjectAssignment.exists?(teacher_id: teacher.id, section_id: section.id) ||
            section.homeroom_teacher_id == teacher.id
    end
end
