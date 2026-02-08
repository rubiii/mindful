# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[edit update destroy]
    before_action :ensure_frame_response, only: %i[new edit]

    def index
      authorize User
      @pagy, @users = pagy(:countless, User.filter(filter_params).order(:email))
    end

    def new
      @user = User.new(locale: I18n.default_locale)
      authorize @user
    end

    def create
      authorize User
      @user = User.invite!(user_params, current_user) do |u|
        u.skip_invitation = !invite_user?
      end

      if @user.errors.empty?
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_users_path, notice: t(".success") }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user
      if @user.update(user_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_users_path, notice: t(".success") }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user
      if @user.destroy
        flash.now[:notice] = t(".success")
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_users_path, notice: t(".success") }
        end
      else
        flash.now[:alert] = t(".failure")
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_users_path, alert: t(".failure") }
        end
      end
    end

    private

    def ensure_frame_response
      redirect_to admin_users_path unless turbo_frame_request?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def invite_user?
      params[:invite_user].present?
    end

    def filter_params
      params.permit(:account_state)
    end

    def user_params
      permitted_attributes(User)
    end
  end
end
