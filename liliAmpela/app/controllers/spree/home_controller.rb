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
        flash[:error] = "Merci de remplir un message ou d'utiliser le mail fourni ci-dessus en remplacement."
      else
        Spree::ContactMailer.contact_email(contact.company_name, contact.email, contact.phone, contact.message).deliver_later
        flash[:success] = 'Votre message a bien été envoyé, notre équipe vous répondra sous peu.'
        redirect_to spree.root_path
      end
    end


    private

    def permitted_parameters(params)
      params.permit(:company_name, :email, :phone, :message)
    end

  end
end
