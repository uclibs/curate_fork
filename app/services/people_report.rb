class PeopleReport < Report

  private

  def self.report_objects
    Person.all
  end

  def self.fields(person = Person.new)
    [
      { pid: person.pid },
      { depositor: person.depositor }, 
      { email: person.email }, 
      { delegates: delegate_emails(person) }
    ]
  end

  def self.delegate_emails(person)
    (person.user.can_receive_deposits_from.collect { |d| d.email }).join(" ") unless person.user.nil?
  end
end
