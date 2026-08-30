# frozen_string_literal: true

module AcademicYears
    class SetCurrent
        include Interactor

        delegate :academic_year, to: :context

        def call
            ActiveRecord::Base.transaction do
                AcademicYear.where(school_id: academic_year.school_id)
                            .where.not(id: academic_year.id)
                            .update_all(is_current: false)
                academic_year.update!(is_current: true)
            end
        end
    end
end
