module Spree
  class HomeController < Spree::StoreController
    def team

    end
    def story

    end
    def contact

    end
    def send_contact_message
      permitted_params = permitted_parameters(params[:contact])
      contact = Contact.new
      contact.company_name = permitted_params[:company_name]
      contact.email = permitted_params[:email]
      contact.phone = permitted_params[:phone]
      contact.message = permitted_params[:message]
      if contact.message.nil?
        flash[:error] = I18n.t('contact_mail_error_message')
      else
        Spree::ContactMailer.contact_email(contact.company_name, contact.email, contact.phone, contact.message).deliver_later
        flash[:success] = I18n.t('contact_mail_normal_message')
        redirect_to spree.root_path
      end
    end


    private

    def permitted_parameters(params)
      params.permit(:company_name, :email, :phone, :message)
    end

  end
end
