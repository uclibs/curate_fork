class EmbargoMailer < ActionMailer::Base

  def notify_open(email, doc_name)
  	mail(from: "scholar@uc.edu",
	  to: email,
	  subject: 'Embargo Released',
	  body: prepare_body_open(doc_name))
	end

  def notify_14_days(email, doc_name)
    mail(from: "scholar@uc.edu",
    to: email,
    subject: '14 days left for embargoed work',
    body: prepare_body_14(doc_name))
  end

  def notify_30_days(email, doc_name)
    mail(from: "scholar@uc.edu",
    to: email,
    subject: '30 days left for embargoed work',
    body: prepare_body_30(doc_name))
  end

  private

  def prepare_body_open(doc_name)
    body = "This email is to notify you that your Scholar@UC item, #{doc_name},\nhas reached its embargo date and is now available to the public. \n\n"
    body += "Sincerely, \n\nThe Scholar@UC Team \n \n"
    body
  end

  def prepare_body_14(doc_name)
    body = "This email is to notify you that your Scholar@UC item, #{doc_name},\nhas 14 days left in embargo before it is made public. \n\n"
    body += "Sincerely, \n\nThe Scholar@UC Team \n \n"
    body
  end

  def prepare_body_30(doc_name)
    body = "This email is to notify you that your Scholar@UC item, #{doc_name},\nhas 30 days left in embargo before it is made public. \n\n"
    body += "Sincerely, \n\nThe Scholar@UC Team \n \n"
    body
  end
end
