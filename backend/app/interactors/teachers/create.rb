# frozen_string_literal: true

module Teachers
    class Create
        include Interactor::Organizer

        organize People::CreateUserAccount, Teachers::CreateProfile
    end
end
