# frozen_string_literal: true

class School < ApplicationRecord
    include Discardable

    has_many :users, dependent: :destroy
    has_one :subscription, dependent: :destroy

    validates :name, presence: true, length: { maximum: 255 }
    validates :slug, presence: true, length: { maximum: 100 },
                     uniqueness: true,
                     format: { with: /\A[a-z0-9-]+\z/, message: "only allows lowercase letters, numbers and dashes" }
    validates :domain, uniqueness: true, allow_nil: true
    validates :timezone, presence: true
    validates :locale, presence: true
    validates :subscription_status, inclusion: { in: %w[active trial suspended cancelled] }
end
