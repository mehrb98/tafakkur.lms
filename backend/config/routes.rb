# frozen_string_literal: true

Rails.application.routes.draw do
    get "health", to: "health#show"
    get "health/ready", to: "health#ready"

    namespace :api do
        api_version(module: "V1", path: { value: "v1" }, defaults: { format: :json }) do
            # Auth
            post "auth/login", to: "auth#login"
            post "auth/refresh", to: "auth#refresh"
            post "auth/logout", to: "auth#logout"
            get "auth/sessions", to: "auth#sessions"
            delete "auth/sessions", to: "auth#logout_all"
            delete "auth/sessions/:id", to: "auth#revoke_session"
            post "auth/password", to: "auth#request_password_reset"
            patch "auth/password", to: "auth#reset_password"
            get "auth/confirmation", to: "auth#confirm_email"

            # School & settings
            resource :school, only: %i[show update]
            resource :settings, only: %i[show update]

            # Identity structure
            resources :academic_years, only: %i[index show create update destroy] do
                resources :semesters, only: %i[index], shallow: true
            end
            resources :semesters, only: %i[show create update destroy]
            resources :departments, only: %i[index show create update destroy]

            # People
            resources :teachers, only: %i[index show create update destroy]
            resources :students, only: %i[index show create update destroy] do
                member do
                    post :enroll
                end
            end
            resources :parents, only: %i[index show create update destroy] do
                member do
                    post :link_student
                    get :children
                end
            end

            # Academic structure
            resources :classes, controller: "school_classes", only: %i[index show create update destroy] do
                resources :sections, only: %i[index], shallow: true
            end
            resources :sections, only: %i[show create update destroy]
            resources :subjects, only: %i[index show create update destroy]
            resources :subject_assignments, only: %i[index create destroy]

            # Academic operations
            resources :attendance_records, only: %i[index update] do
                collection do
                    post :bulk
                end
            end
            resources :grades, only: %i[index show create update destroy]
        end
    end

    # Swagger UI at /api — OpenAPI spec at /api/openapi (avoids /api/v1 route clash)
    mount Rswag::Api::Engine => "/api/openapi"
    mount Rswag::Ui::Engine => "/api"
end
