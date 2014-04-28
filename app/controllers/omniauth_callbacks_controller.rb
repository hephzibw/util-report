class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    p "1"*100
    p request.env["omniauth.auth"]
    p "1"*100

    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      flash.notice = "Signed in Through Google!"
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
      redirect_to new_user_registration_url
    end
  end
end