class Api::V1::MainController < ApplicationController

  def contact_us
    MainMailer.contact_us(params[:email],params[:name],params[:lastname],params[:problem]).deliver_later
    message
  end

  def send_email
    MainMailer.send_email(params[:emails],params[:title],params[:body],params[:subject]).deliver_later
    message
  end

  def request_chef
    MainMailer.request_chef(params[:email],params[:name],params[:lastname],params[:expertise],params[:address],params[:speciality]).deliver_later
    MainMailer.request_chef_thanks(params[:email],params[:name],params[:lastname]).deliver_later
    message
  end

  protected
    def message
      render json: { data: {
          status: "Success",
          message: "We have sent the email"
        }
      } , status: 200
    end
end
