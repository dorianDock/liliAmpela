module Spree
  class ContactMailer < BaseMailer
    def contact_email(company, email, phone, message)
      new_contact = Contact.new

      new_contact.company_name = company
      new_contact.email = email
      new_contact.phone = phone
      new_contact.message = message

      @contact = new_contact
      company = (' - '+@contact.company_name) || ' - '
      subject = 'Contact'+company+@contact.email
      mail(to: 'contact@ubris.io', from: @contact.email, subject: subject)
    end


  end
end
