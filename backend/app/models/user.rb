# frozen_string_literal: true

class User < ApplicationRecord
    include Discardable

    devise :database_authenticatable, :recoverable, :confirmable, :trackable,
           reconfirmable: false

    belongs_to :school
    has_many :refresh_tokens, dependent: :destroy
    has_many :device_sessions, dependent: :destroy

    ROLES = %w[admin teacher student parent].freeze

    enum :role, ROLES.index_with(&:itself), validate: true

    validates :email, presence: true,
                      format: { with: URI::MailTo::EMAIL_REGEXP },
                      uniqueness: { scope: :school_id, case_sensitive: false }

    validates :first_name, presence: true, length: { maximum: 100 }
    validates :last_name, presence: true, length: { maximum: 100 }
    validates :password, length: { minimum: 12 }, if: :password_required?

    before_validation :normalize_email

    def full_name
        "#{first_name} #{last_name}"
    end

    def email_verified?
        confirmed_at.present?
    end

    # Devise looks up users globally by default; scope authentication lookups
    # per school at the interactor level instead.
    def self.find_for_authentication(conditions)
        kept.find_by(conditions)
    end

    protected

    # Devise validatable is not used (password rules are custom), so replicate
    # the required password checks here.
    def password_required?
        !persisted? || password.present?
    end

    # Devise's own mailer requires routing mappings this API does not define.
    # Route notifications through our Sidekiq-backed jobs instead.
    def send_devise_notification(notification, *args)
        case notification

        when :confirmation_instructions
            SendEmailVerificationJob.perform_later(id, args.first)
        when :reset_password_instructions
            SendPasswordResetJob.perform_later(id, args.first)
        end
    end

    private

    def normalize_email
        self.email = email.to_s.downcase.strip
    end
end
