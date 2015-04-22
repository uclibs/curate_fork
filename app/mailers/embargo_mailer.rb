class EmbargoMailer < ActionMailer::Base

  def notify(email, doc_name)
  	mail(from: "scholar@uc.edu",
	  to: email,
	  subject: 'Embargo Released',
	  body: prepare_body(doc_name))
	end

  private

  def prepare_body(doc_name)
    body = "This email is to notify you that your Scholar@UC item, #{doc_name},\nhas reached its embargo date and is now available to the public. \n\n"
    body += "Sincerely, \n\nThe Scholar@UC Team \n \n"
    body
 end
end
