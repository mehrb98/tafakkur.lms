# frozen_string_literal: true

module Parents
    class Create
        include Interactor::Organizer

        organize People::CreateUserAccount, Parents::CreateProfile
    end
end
