# frozen_string_literal: true

module Students
    class Create
        include Interactor::Organizer

        organize People::CreateUserAccount, Students::CreateProfile
    end
end
