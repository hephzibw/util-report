class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_login

  def google_oauth2
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      flash.notice = "Signed in Through Google!"
      sign_in_and_redirect user
    else
      flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
      redirect_to new_user_registration_url
    end
  end
end