class WelcomePageController < ApplicationController
  respond_to(:html)

  add_breadcrumb 'Welcome Page', lambda {|controller| controller.request.path }

  def new
  end

  def create
    if user_just_waived_welcome_page?
      current_user.waive_welcome_page!
      redirect_to landing_page
      flash[:notice] = "Thanks! You can always find the welcome page in our help menus."
    else
      redirect_to landing_page
    end
  end

  def user_just_waived_welcome_page?
    params[:waive_welcome_page] == "1"
  end

  def skip_new_user_help?
    return true unless user_signed_in? 
    current_user.user_does_not_require_profile_update
  end
  helper_method :skip_new_user_help?

  def user_waived_welcome_page?
    return true unless user_signed_in? 
    current_user.waived_welcome_page
  end
  helper_method :user_waived_welcome_page?

end
