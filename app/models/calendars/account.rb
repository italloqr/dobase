# frozen_string_literal: true

module Calendars
  class Account < ApplicationRecord
    include EncryptedPassword

    self.table_name = "calendar_accounts"

    belongs_to :tool
    has_many :calendars, class_name: "Calendars::Calendar", foreign_key: "calendar_account_id", dependent: :destroy
    has_many :events, through: :calendars

    accepts_nested_attributes_for :calendars

    validates :username, presence: true, unless: :local?
    validates :encrypted_password, presence: true, unless: :local?

    before_validation :normalize_local_credentials

    PROVIDERS = %w[fastmail icloud nextcloud google custom local].freeze

    def local?
      provider == "local"
    end

    private

    def normalize_local_credentials
      return unless local?

      self.username = "" if username.blank?
      self.encrypted_password = "" if encrypted_password.blank?
    end

    def encryption_salt
      "calendar account password"
    end
  end
end
