# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentPolicy, type: :policy do
    let(:school) { create(:school) }
    let(:admin) { create(:user, :admin, school: school) }
    let(:student) { create(:student, school: school) }

    describe "role matrix" do
        it "permits admin full access" do
            policy = described_class.new(admin, student)
            expect(policy.show?).to be(true)
            expect(policy.create?).to be(true)
            expect(policy.update?).to be(true)
            expect(policy.destroy?).to be(true)
        end

        it "permits student to see only self" do
            policy = described_class.new(student.user, student)
            expect(policy.show?).to be(true)
            expect(policy.update?).to be(false)

            other = create(:student, school: school)
            expect(described_class.new(student.user, other).show?).to be(false)
        end

        it "permits parent to see only linked children" do
            parent = create(:parent, school: school)
            create(:parent_student, parent: parent, student: student)
            unlinked = create(:student, school: school)

            expect(described_class.new(parent.user, student).show?).to be(true)
            expect(described_class.new(parent.user, unlinked).show?).to be(false)
        end

        it "permits assigned teacher, denies unassigned teacher" do
            teacher = create(:teacher, school: school)
            section = create(:section, school_class: create(:school_class, school: school),
                                       homeroom_teacher: teacher)
            create(:enrollment, student: student, section: section)
            outsider = create(:teacher, school: school)

            expect(described_class.new(teacher.user, student).show?).to be(true)
            expect(described_class.new(outsider.user, student).show?).to be(false)
        end

        it "denies admin of another school" do
            foreign_admin = create(:user, :admin)
            expect(described_class.new(foreign_admin, student).show?).to be(false)
        end
    end

    describe "Scope" do
        it "returns nothing for a user with no profile" do
            teacher_user = create(:user, :teacher, school: school)
            resolved = described_class::Scope.new(teacher_user, Student).resolve
            expect(resolved).to be_empty
        end
    end
end
