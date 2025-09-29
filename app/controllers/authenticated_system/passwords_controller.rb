module AuthenticatedSystem
  class PasswordsController < ApplicationController
    allow_unauthenticated_access
    before_action :set_user_by_token, only: %i[ edit update ]

    def new
    end

    def create
      if user = User.find_by(email: params[:email])
        PasswordsMailer.reset(user).deliver_later
      end

      redirect_to authenticated_system_login_path, notice: "Password reset instructions sent (if user with that email address exists)."
    end

    def edit
    end

    def update
      if @user.update(params.permit(:password, :password_confirmation))
        redirect_to authenticated_system_login_path, notice: "Password has been reset."
      else
        redirect_to edit_authenticated_system_password_path(params[:token]), alert: "Passwords did not match."
      end
    end

    private
      def set_user_by_token
        @user = User.find_by_password_reset_token!(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to new_authenticated_system_password_path, alert: "Password reset link is invalid or has expired."
      end
  end
end