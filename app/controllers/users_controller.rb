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

  def globalProgress
    if $currentPetitionUser['id'] != nil
      payload = []
      grades = []
      subject = {}
      if params[:role] != nil
        role = params[:role]
        case request['role']
          when 'contentLeader'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              processed = 0
              received = 0
              notReceived = 0
              recorded = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                totalVideos = totalVideos + cp.vdms.reject{|r| r.status == 'DESTROYED'}.count
                notReceived = notReceived + cp.vdms.where(:status => 'no recibido').count
                returned = returned + cp.vdms.where(:status => 'rechazado').count
                processed = processed + cp.vdms.where(:status => 'procesado').count
                received = received + cp.vdms.where(:status => 'recibido').count
                recorded = recorded + ProductionDpt.find_by_sql("Select * from production_dpts pdpt, vdms v where v.classes_planification_id = " + cp.id.to_s + " and pdpt.vdm_id = v.id and pdpt.status = 'recorded'").count
              end
              effectiveness = number_with_precision((processed.to_f/totalVideos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: totalVideos,
                  received: received,
                  returned: returned,
                  processed: processed,
                  notReceived: notReceived,
                  effectiveness: effectiveness,
                  recorded: recorded
              }
              i += 1
            end
          when 'production'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              received = 0
              recorded = 0
              assigned = 0
              approved = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.production_dpt != nil
                    totalVideos += 1
                  end
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
              effectiveness = number_with_precision(((recorded.to_f + approved.to_f)/totalVideos.to_f)*100, :precision => 2)
              subject = {
                  name: sp.subject.name + ' ' + sp.subject.grade.name
              }
              payload[i] ={
                  subject: subject,
                  teacher: sp.teacher,
                  totalVideos: totalVideos,
                  received: received,
                  returned: returned,
                  assigned: assigned,
                  approved: approved,
                  effectiveness: effectiveness,
                  recorded: recorded
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
          when 'designLeader'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              assigned = 0
              approved = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.design_dpt != nil
                    totalVideos += 1
                  end
                  if vdm.design_dpt != nil && vdm.design_dpt.status == 'asignado'
                    assigned += 1
                  end
                  if vdm.design_dpt != nil && vdm.design_dpt.status == 'rechazado'
                    returned += 1
                  end
                  if vdm.design_dpt != nil && vdm.design_dpt.status == 'aprobado'
                    approved += 1
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
                  approved: approved
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
          when 'postProLeader'
            subjectPlannings = SubjectPlanification.all
            payload = []
            i = 0
            subjectPlannings.each do |sp|
              totalVideos = 0
              returned = 0
              assigned = 0
              approved = 0
              sp.classes_planifications.reject{|r| r.status == 'DESTROYED'}.each do |cp|
                cp.vdms.reject{|r| r.status == 'DESTROYED'}.each do |vdm|
                  if vdm.post_prod_dpt != nil
                    totalVideos += 1
                  end
                  if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.status == 'asignado'
                    assigned += 1
                  end
                  if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.status == 'rechazado'
                    returned += 1
                  end
                  if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.status == 'aprobado'
                    approved += 1
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
                  approved: approved
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
        end

      end

      render :json => { data: payload.as_json, status: 'SUCCESS'}, :status => 200
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :password, :role, :profilePicture, :status)
    end
end
