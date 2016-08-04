class UserNotifier < ApplicationMailer
  default :from => 'DawereProcessManager.com'

  def send_mail
    mail( :to => ['alfredoescalante89@gmail.com'],
          :subject => 'mail prueba de dawereProcessManager' )
  end

  def send_assigned_to_production(vdmList)
    @vdmList = vdmList
    mail( :to => ['hectorug@gmail.com'],
          :subject => 'Se han asignado nuevos MDT a producción' )
  end
end
