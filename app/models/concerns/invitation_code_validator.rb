# app/models/concerns/invitation_code_validator.rb
module InvitationCodeValidator
  extend ActiveSupport::Concern

  included do
    validates :invitation_code, presence: true, on: :create
    validate :valid_invitation_code, on: :create
  end

  private

  def valid_invitation_code
    unless VALID_INVITATION_CODES.include?(invitation_code)
      errors.add(:invitation_code, "is not valid")
    end
  end
end
