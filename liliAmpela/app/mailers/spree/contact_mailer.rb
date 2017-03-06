module Spree
  class ContactMailer < BaseMailer
    def contact_email(contact)
      @contact = contact
      company = (' - '+@contact.company_name) || ' - '
      subject = 'Contact'+company+@contact.email
      mail(to: 'contact@ubris.io', from: @contact.email, subject: subject)
    end

    private
  end
end