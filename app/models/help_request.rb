require 'browser'
class HelpRequest < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :how_can_we_help_you,
    :message => "Please tell us about the problem or issue you are having with #{I18n.t('sufia.product_name')}."

  after_save :send_notification

  def browser_name
    parse_user_agent
    @browser.name
  end

  def platform
    parse_user_agent
    @browser.platform
  end

  def sender_email
    if user
      user.email || I18n.t('sufia.help_email')
    else
      I18n.t('sufia.help_email')
    end
  end

  def user_name
    if user
      user.user_key || 'Unknown'
    else
      'Unknown'
    end
  end

  private

  def parse_user_agent
    @browser ||= Browser.new(:ua => user_agent)
  end

  def send_notification
    Sufia.queue.push(NotificationWorker.new(id))
  end
end
