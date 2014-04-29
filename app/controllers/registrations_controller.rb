class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_login
end