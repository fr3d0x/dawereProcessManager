class UsersController < ApplicationController
  require 'jwt'
  before_action :authenticate, :except => [:login]
  before_action :set_user, only: [:show, :update, :destroy]
  include ActionView::Helpers::NumberHelper

  # GET /users
  # GET /users.json

  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    render json: @user
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    head :no_content
  end

  def login
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      user = User.find_by_username(parameters['username'])
      if user
        if user.password == parameters['password']
          payload = {
              id: user.id,
              username: user.username,
              name: user.employee.firstName,
              email: user.employee.email,
              cedula: user.employee.personalId,
              profile_picture: user.profilePicture,
              roles: user.roles.as_json
          }
          token = JWT.encode(payload, $secretKey, 'HS256')
          render :json => { data: token, status: 'SUCCESS'}, :status => 200
        else
          render :json => { msg: 'El password del usuario no es correcto.', status: 'UNAUTHORIZEDLOGIN'}, :status => :unauthorized
        end
      else
        render :json => { msg: 'Usuario no encontrado.', status: 'UNAUTHORIZEDLOGIN'}, :status => 404
      end
    else
    render :json => { status: 'UNAUTHORIZED', msg: 'No Autorizado'}, :status => :unauthorized
    end
  end

  def employee_progress
    if $currentPetitionUser['id'] != nil
      payload = []
      if params[:role] != nil
        case request['role']
          when 'contentAnalist'
            user = User.find($currentPetitionUser['id'])
            subject_plannings = user.subject_planifications
            i = 0
            subject_plannings.each do |sp|
              total_videos = 0
              returned = 0
              processed = 0
              received = 0
              not_received = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                total_videos = total_videos + cp.vdms.reject{|r| r.status == 'DESTROYED'}.count
                not_received = not_received + cp.vdms.where(:status => 'no recibido').count
                returned = returned + cp.vdms.where(:status => 'rechazado').count
                processed = processed + cp.vdms.where(:status => 'procesado').count
                received = received + cp.vdms.where(:status => 'recibido').count
              end
              effectiveness = number_with_precision((processed.to_f/total_videos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: total_videos,
                  received: received,
                  returned: returned,
                  processed: processed,
                  notReceived: not_received,
                  effectiveness: effectiveness,
              }
              i += 1
            end
          when 'editor'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              approved = 0
              assigned = 0
              edited = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.production_dpt != nil
                    if vdm.production_dpt.production_dpt_assignment != nil
                      if vdm.production_dpt.production_dpt_assignment.user_id == $currentPetitionUser['id']
                        totalVideos += 1
                        case vdm.production_dpt.production_dpt_assignment.status
                          when 'rechazado'
                            returned += 1
                          when 'asignado'
                            assigned += 1
                          when 'editado'
                            edited += 1
                          when 'aprobado'
                            approved += 1
                        end
                      end
                    end
                  end
                end
              end
              effectiveness = number_with_precision(((approved.to_f)/totalVideos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: totalVideos,
                  assigned: assigned,
                  returned: returned,
                  approved: approved,
                  effectiveness: effectiveness
              }
              i += 1
            end
          when 'designer'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              assigned = 0
              approved = 0
              designed = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.design_dpt != nil
                    if vdm.design_dpt.design_assignment != nil
                      if vdm.design_dpt.design_assignment.user_id == $currentPetitionUser['id']
                        totalVideos += 1

                        case vdm.design_dpt.design_assignment.status
                          when 'asignado'
                            assigned += 1
                          when 'diseñado'
                            designed += 1
                          when 'rechazado'
                            returned += 1
                          when 'aprobado'
                            approved += 1
                        end
                      end
                    end
                  end
                end
              end
              effectiveness = number_with_precision(((approved.to_f)/totalVideos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: totalVideos,
                  assigned: assigned,
                  returned: returned,
                  effectiveness: effectiveness,
                  approved: approved,
                  designed: designed
              }
              i += 1
            end
          when 'post-producer'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              assigned = 0
              approved = 0
              finished = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.post_prod_dpt != nil
                    if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                      if vdm.post_prod_dpt.post_prod_dpt_assignment.user_id == $currentPetitionUser['id']
                        totalVideos += 1
                        case vdm.post_prod_dpt.post_prod_dpt_assignment.status
                          when 'asignado'
                            assigned += 1
                          when 'rechazado'
                            returned += 1
                          when 'aprobado'
                            approved += 1
                          when 'terminado'
                            finished += 1
                        end
                      end
                    end
                  end
                end
              end
              effectiveness = number_with_precision(((approved.to_f - returned.to_f)/totalVideos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: totalVideos,
                  assigned: assigned,
                  returned: returned,
                  effectiveness: effectiveness,
                  approved: approved,
                  finished: finished
              }
              i += 1
            end
          when 'qa-analyst'
            subject_plannings = SubjectPlanification.all
            payload = []
            i = 0
            subject_plannings.each do |sp|
              total_videos = 0
              returned = 0
              assigned = 0
              approved = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.qa_dpt != nil
                    if vdm.qa_dpt.qa_assignment != nil
                      if vdm.qa_dpt.qa_assignment.user_id == $currentPetitionUser['id']
                        total_videos += 1
                        case vdm.qa_dpt.qa_assignment.status
                          when 'asignado'
                            assigned += 1
                          when 'rechazado'
                            returned += 1
                          when 'aprobado'
                            approved += 1
                        end
                      end
                    end
                  end
                end
              end
              effectiveness = number_with_precision(((approved.to_f + returned.to_f)/total_videos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  totalVideos: total_videos,
                  assigned: assigned,
                  returned: returned,
                  effectiveness: effectiveness,
                  approved: approved,
              }
              i += 1
            end
        end

      end

      render :json => { data: payload.as_json, status: 'SUCCESS'}, :status => 200
    end
  end

  def global_progress
    payload = []
    from = 1.month.ago.to_date
    to = DateTime.now.to_date
    if $currentPetitionUser['id'] != nil
      if params[:progress_type]
        if params[:date_from] != 'null' && params[:date_to] != 'null'
          from = params[:date_from].to_date
          to = params[:date_to].to_date
        end
        case params[:progress_type]
          when 'content_department'
            if params[:role] == 'contentLeader' || params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                processed = 0
                received = 0
                not_received = 0
                recorded = 0
                sp.classes_planifications.where(:created_at => from..to).reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  total_videos = total_videos + cp.vdms.reject{|r| r.status == 'DESTROYED'}.count
                  not_received = not_received + cp.vdms.where(:status => 'no recibido').count
                  returned = returned + cp.vdms.where(:status => 'rechazado').count
                  processed = processed + cp.vdms.where(:status => 'procesado').count
                  received = received + cp.vdms.where(:status => 'recibido').count
                end
                effectiveness = number_with_precision((processed.to_f/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                     subject: subject,
                     teacher: sp.teacher,
                     totalVideos: total_videos,
                     received: received,
                     returned: returned,
                     processed: processed,
                     notReceived: not_received,
                     effectiveness: effectiveness,
                     recorded: recorded
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'content_analysts'
            if params[:role] == 'contentLeader' || params[:role] == 'productManager'
              employees = User.joins(:roles).where(:roles => {:role => ['contentAnalist', 'contentLeade']})
              employees.each do |emp|
                total_videos = 0
                returned = 0
                processed = 0
                received = 0
                not_received = 0
                subject_plannings = emp.subject_planifications
                subject_plannings.each do |sp|
                  sp.classes_planifications.where(:created_at => from..to).reject{|r| r.status == 'DESTROYED'}.each do |cp|
                    total_videos = total_videos + cp.vdms.reject{|r| r.status == 'DESTROYED'}.count
                    not_received = not_received + cp.vdms.where(:status => 'no recibido').count
                    returned = returned + cp.vdms.where(:status => 'rechazado').count
                    processed = processed + cp.vdms.where(:status => 'procesado').count
                    received = received + cp.vdms.where(:status => 'recibido').count
                  end
                end
                effectiveness = number_with_precision((processed.to_f/total_videos.to_f)*100, :precision => 2)
                payload.push({
                     analyst: emp.employee.firstName + ' ' + emp.employee.firstSurname,
                     totalVideos: total_videos,
                     received: received,
                     returned: returned,
                     processed: processed,
                     notReceived: not_received,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end

          when 'production'
            if params[:role] == 'production' || params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              payload = []
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                received = 0
                recorded = 0
                assigned = 0
                approved = 0
                sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                    if vdm.production_dpt != nil && vdm.production_dpt.created_at >= from && vdm.production_dpt.created_at <= to
                      if vdm.production_dpt.status != nil && vdm.production_dpt.status != 'no asignado'
                        total_videos += 1
                        if vdm.production_dpt != nil && vdm.production_dpt.status == 'rechazado'
                          returned += 1
                        end
                        if vdm.production_dpt != nil && vdm.production_dpt.status == 'grabado'
                          recorded += 1
                        end
                        if vdm.production_dpt != nil && vdm.production_dpt.status == 'asignado'
                          assigned += 1
                        end
                        if vdm.production_dpt != nil && vdm.production_dpt.status == 'aprobado'
                          approved += 1
                        end
                      end
                    end
                  end
                end
                effectiveness = number_with_precision(((recorded.to_f + approved.to_f)/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                    subject: subject,
                    teacher: sp.teacher,
                    totalVideos: total_videos,
                    received: received,
                    returned: returned,
                    assigned: assigned,
                    approved: approved,
                    effectiveness: effectiveness,
                    recorded: recorded
                })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'edition'
            if params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              payload = []
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                assigned = 0
                approved = 0
                sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                    if vdm.production_dpt != nil && vdm.production_dpt.production_dpt_assignment != nil && vdm.production_dpt.production_dpt_assignment.created_at >= from && vdm.production_dpt.production_dpt_assignment.created_at <= to
                      if vdm.production_dpt.production_dpt_assignment.status != nil && vdm.production_dpt.production_dpt_assignment.status != 'no asignado'
                        total_videos += 1
                        if vdm.production_dpt.production_dpt_assignment.status == 'asignado'
                          assigned += 1
                        end
                        if vdm.production_dpt.production_dpt_assignment.status == 'rechazado'
                          returned += 1
                        end
                        if vdm.production_dpt.production_dpt_assignment.status == 'aprobado'
                          approved += 1
                        end
                      end
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                     subject: subject,
                     totalVideos: total_videos,
                     returned: returned,
                     assigned: assigned,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'editors'
            if params[:role] == 'production' || params[:role] == 'productManager'
              employees = User.joins(:roles).where(:roles => {:role => 'editor'})
              employees.each do |emp|
                total_videos = 0
                returned = 0
                approved = 0
                assigned = 0
                edited = 0
                assignments = emp.production_dpt_assignments.where(:created_at => from..to)
                assignments.each do |as|
                  if as.status != nil && as.status != 'no asignado'
                    total_videos += 1
                    case as.status
                      when 'rechazado'
                        returned += 1
                      when 'asignado'
                        assigned += 1
                      when 'editado'
                        edited += 1
                      when 'aprobado'
                        approved += 1
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                payload.push({
                     editor: emp.employee.firstName + ' ' + emp.employee.firstSurname,
                     totalVideos: total_videos,
                     assigned: assigned,
                     returned: returned,
                     edited: edited,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'design'
            if params[:role] == 'designLeader' || params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              payload = []
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                assigned = 0
                approved = 0
                sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                    if vdm.design_dpt != nil && vdm.design_dpt.created_at >= from && vdm.design_dpt.created_at <= to
                      if vdm.design_dpt.status != nil && vdm.design_dpt.status != 'no asignado'
                        total_videos += 1
                        if vdm.design_dpt.status == 'asignado'
                          assigned += 1
                        end
                        if vdm.design_dpt.status == 'rechazado'
                          returned += 1
                        end
                        if vdm.design_dpt.status == 'aprobado'
                          approved += 1
                        end
                      end
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                     subject: subject,
                     totalVideos: total_videos,
                     returned: returned,
                     assigned: assigned,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'designers'
            if params[:role] == 'designLeader' || params[:role] == 'productManager'
              employees = User.joins(:roles).where(:roles => {:role => 'designer'})
              employees.each do |emp|
                total_videos = 0
                returned = 0
                approved = 0
                assigned = 0
                designed = 0
                assignments = emp.design_assignments.where(:created_at => from..to)
                assignments.each do |as|
                  if as.status != nil && as.status != 'no asignado'
                    total_videos += 1
                    case as.status
                      when 'asignado'
                        assigned += 1
                      when 'diseñado'
                        designed += 1
                      when 'rechazado'
                        returned += 1
                      when 'aprobado'
                        approved += 1
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                payload.push({
                     designer: emp.employee.firstName + ' ' + emp.employee.firstSurname,
                     totalVideos: total_videos,
                     assigned: assigned,
                     returned: returned,
                     designed: designed,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'post-production'
            if params[:role] == 'postProLeader' || params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              payload = []
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                assigned = 0
                approved = 0
                sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                    if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.created_at >= from && vdm.post_prod_dpt.created_at <= to
                      if vdm.post_prod_dpt.status != nil && vdm.post_prod_dpt.status != 'no asignado'
                        total_videos += 1
                        if vdm.post_prod_dpt.status == 'asignado'
                          assigned += 1
                        end
                        if vdm.post_prod_dpt.status == 'rechazado'
                          returned += 1
                        end
                        if vdm.post_prod_dpt.status == 'aprobado'
                          approved += 1
                        end
                      end
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                   subject: subject,
                   totalVideos: total_videos,
                   returned: returned,
                   assigned: assigned,
                   approved: approved,
                   effectiveness: effectiveness,
               })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'post-producers'
            if params[:role] == 'postProLeader' || params[:role] == 'productManager'
              employees = User.joins(:roles).where(:roles => {:role => 'post-producer'})
              employees.each do |emp|
                total_videos = 0
                returned = 0
                approved = 0
                assigned = 0
                finished = 0
                assignments = emp.post_prod_dpt_assignments.where(:created_at => from..to)
                assignments.each do |as|
                  if as.status != nil && as.status != 'no asignado'
                    total_videos += 1
                    case as.status
                      when 'asignado'
                        assigned += 1
                      when 'terminado'
                        finished += 1
                      when 'rechazado'
                        returned += 1
                      when 'aprobado'
                        approved += 1
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                payload.push({
                     post_producer: emp.employee.firstName + ' ' + emp.employee.firstSurname,
                     totalVideos: total_videos,
                     assigned: assigned,
                     returned: returned,
                     finished: finished,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'qa'
            if params[:role] == 'qa' || params[:role] == 'productManager'
              subject_plannings = SubjectPlanification.all
              payload = []
              subject_plannings.each do |sp|
                total_videos = 0
                returned = 0
                assigned = 0
                approved = 0
                sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                  cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                    if vdm.qa_dpt != nil && vdm.qa_dpt.created_at >= from && vdm.qa_dpt.created_at <= to
                      if vdm.qa_dpt.status != nil && vdm.qa_dpt.status != 'no asignado'
                        total_videos += 1
                        if vdm.qa_dpt.status == 'asignado'
                          assigned += 1
                        end
                        if vdm.qa_dpt.status == 'rechazado'
                          returned += 1
                        end
                        if vdm.qa_dpt.status == 'aprobado'
                          approved += 1
                        end
                      end
                    end
                  end
                end
                effectiveness = number_with_precision((approved.to_f/total_videos.to_f)*100, :precision => 2)
                subject = {
                    name: sp.subject.name + ' ' + sp.subject.grade.name
                }
                payload.push({
                     subject: subject,
                     totalVideos: total_videos,
                     rejected: returned,
                     assigned: assigned,
                     approved: approved,
                     effectiveness: effectiveness,
                 })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          when 'qa-analysts'
            if params[:role] == 'qa' || params[:role] == 'productManager'
              employees = User.joins(:roles).where(:roles => {:role => 'qa-analyst'})
              employees.each do |emp|
                total_videos = 0
                rejected = 0
                approved = 0
                assigned = 0
                assignments = emp.qa_assignments.where(:created_at => from..to)
                assignments.each do |as|
                  if as.status != nil && as.status != 'no asignado'
                    total_videos += 1
                    case as.status
                      when 'asignado'
                        assigned += 1
                      when 'rechazado'
                        rejected += 1
                      when 'aprobado'
                        approved += 1
                    end
                  end
                end
                effectiveness = number_with_precision(((approved+rejected).to_f/total_videos.to_f)*100, :precision => 2)
                payload.push({
                   qa_analyst: emp.employee.firstName + ' ' + emp.employee.firstSurname,
                   totalVideos: total_videos,
                   assigned: assigned,
                   rejected: rejected,
                   approved: approved,
                   effectiveness: effectiveness,
               })
              end
            else
              raise Exceptions::InvalidRoleException
            end
          else
            render :json => { data: nil, status: 'FAILED', msg: 'Invalid petition'}, :status => 500
        end
      end
    end
    render :json => { data: payload, status: 'SUCCESS'}, :status => 200
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :password, :role, :profilePicture, :status)
    end
end
