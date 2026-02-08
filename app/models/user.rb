# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  locale                 :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("user"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  include Filterable

  enum :role, { user: 0, admin: 1 }, default: :user

  def self.available_locales = I18n.available_locales.map(&:to_s)

  # Devise modules to include. Other available modules:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # https://github.com/heartcombo/devise?tab=readme-ov-file#configuring-models
  devise :database_authenticatable,
         :invitable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  scope :not_pending_invitation, -> { where(invitation_token: nil).or(where.not(invitation_accepted_at: nil)) }

  scope :filter_by_account_state, ->(state) {
    case state.to_sym
    when :invitation_pending
      where.not(invitation_token: nil).where(invitation_accepted_at: nil)
    when :active_password_reset
      not_pending_invitation.where.not(reset_password_token: nil)
    when :active
      not_pending_invitation.where(reset_password_token: nil)
    when :locked
      none # Add logic here if you add :lockable to Devise
    when :confirmation_pending
      none # Add logic here if you add :confirmable to Devise
    else
      all
    end
  }

  validates :locale, inclusion: { in: User.available_locales }

  def account_state
    if respond_to?(:access_locked?) && access_locked?
      :locked
    elsif respond_to?(:invited_to_sign_up?) && invited_to_sign_up?
      :invitation_pending
    elsif respond_to?(:confirmed?) && !confirmed?
      :confirmation_pending
    elsif reset_password_token.present?
      :active_password_reset
    else
      :active
    end
  end
end
