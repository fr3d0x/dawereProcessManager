class UserNotifier < ApplicationMailer
  default :from => 'DawereProcessManager.com'


  def send_mail
    mail( :to => ['alfredoescalante89@gmail.com'],
          :subject => 'mail prueba de dawereProcessManager' )
  end
end
