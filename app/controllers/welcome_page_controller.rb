class WelcomePageController < ApplicationController
  before_filter :authenticate_user!
  respond_to(:html)

  add_breadcrumb 'Welcome Page', lambda {|controller| controller.request.path }

  with_themed_layout '1_column'
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
    params[:commit] == waive_welcome_page_text
  end

  WAIVE_WELCOME_PAGE_TEXT = "I don't need to see this page anymore."
  DO_NOT_WAIVE_WELCOME_PAGE_TEXT = "Continue"

  def waive_welcome_page_text
    WAIVE_WELCOME_PAGE_TEXT
  end
  helper_method :waive_welcome_page_text

  def do_not_waive_welcome_page_text
    DO_NOT_WAIVE_WELCOME_PAGE_TEXT
  end
  helper_method :do_not_waive_welcome_page_text

  def skip_new_user_help?
    current_user.user_does_not_require_profile_update
  end
  helper_method :skip_new_user_help?

  def user_waived_welcome_page?
    current_user.waived_welcome_page
  end
  helper_method :user_waived_welcome_page?

end
