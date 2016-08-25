class UserNotifier < ApplicationMailer
  default :from => 'DawereProcessManager.com'

  def send_mail
    mail( :to => ['alfredoescalante89@gmail.com'],
          :subject => 'mail prueba de dawereProcessManager' )
  end

  def send_assigned_to_production(vdmList)
    @vdmList = vdmList
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'production' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se han asignado nuevos MDT a producción' )
  end
  def send_assigned_to_editor(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se te han asignado nuevos MDT' )
  end
  def send_assigned_to_designLeader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.* from employees e, users u, roles r where r.role = 'designLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se han asignado nuevos MDT a diseño' )
  end
  def send_assigned_to_designer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se te han asignado nuevos MDT' )
  end
  def send_assigned_to_post_prod_leader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'postProLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se han asignado nuevos MDT a post-produccion' )
  end
  def send_assigned_to_post_producer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se te han asignado nuevos MDT' )
  end

  def send_rejected_to_production(vdmList)
    @vdmList = vdmList
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'production' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a producción' )
  end
  def send_rejected_to_editor(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT de edicion' )
  end
  def send_rejected_to_designLeader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.* from employees e, users u, roles r where r.role = 'designLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a diseño' )
  end
  def send_rejected_to_designer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT a diseno' )
  end
  def send_rejected_to_post_prod_leader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'postProLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a post-produccion' )
  end
  def send_rejected_to_post_producer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT a post-produccion' )
  end



  def send_approved_to_production(vdmList)
    @vdmList = vdmList
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'production' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a producción' )
  end
  def send_approved_to_editor(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT de edicion' )
  end
  def send_approved_to_designLeader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.* from employees e, users u, roles r where r.role = 'designLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a diseño' )
  end
  def send_approved_to_designer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT a diseno' )
  end
  def send_approved_to_post_prod_leader(vdm)
    @vdm = vdm
    @employees = Employee.find_by_sql("Select e.email from employees e, users u, roles r where r.role = 'postProLeader' and u.id = r.user_id and e.id = u.employee_id")
    mail( :to => [@employees.map(&:email)],
          :subject => 'Se ha rechazado un MDT a post-produccion' )
  end
  def send_approved_to_post_producer(vdm, user)
    @vdm = vdm
    @user = user
    mail( :to => [user.email],
          :subject => 'Se ha rechazado un MDT a post-produccion' )
  end

end
