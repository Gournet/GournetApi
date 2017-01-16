class MainMailer < ApplicationMailer

  def contact_us(email,name,lastname,problem)
    @name = name
    @lastname = lastname
    @problem = problem
    pretty_email = %("#{name}" <#{email}>)
    mail(to: pretty_email, subject: 'Gracias por las commentarios',cc: Admin.pluck(:email))
  end

  def send_email(emails,title,body,subject)
    @title = title
    @body = body
    mail(to: emails, subject: subject, cc: Admin.pluck(:email))
  end

  def request_chef(email,name,lastname,expertise,address,speciality)
    @name = name
    @email = email
    @lastname = lastname
    @expertise = expertise
    @address = address
    @speciality = speciality
    mail(to: Admin.pluck(:email), subject: 'Solicitud para chef',template_name: "request_chef")
  end

  def request_chef_thanks(email,name,lastname)
    pretty_email = %("#{name}" <#{email}>)
    mail(to: pretty_email, subject: 'Gracias por tu solicitud', template_name: "request_chef_thanks")

  end

end
