class UsersController < ApplicationController
  require 'jwt'
  before_action :authenticate, :except => [:login]
  before_action :set_user, only: [:show, :update, :destroy]


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
          render :json => { data: 'El password del usuario no es correcto.'}
        end
      else
        render :json => { data: 'Usuario no encontrado.'}
      end
    else
    render :json => { status: 'UNAUTHORIZED', msg: 'No Autorizado'}, :status => :unauthorized
    end
  end

  def globalProgress
    if $currentPetitionUser['id'] != nil
      subjectPlannings = SubjectPlanification.where(:user_id => $currentPetitionUser['id']).all
      payload = []
      i = 0
      subjectPlannings.each do |sp|
        totalVideos = 0
        returned = 0
        processed = 0
        received = 0
        sp.classes_planifications.each do |cp|
        totalVideos = totalVideos + cp.vdms.count
        returned = returned + cp.vdms.where(:status => 'returned').count
        processed = processed + cp.vdms.where(:status => 'processed').count
        received = received + cp.vdms.where(:status => 'received').count
        end
        payload[i] ={
            subject: sp.subject,
            teacher: sp.teacher,
            totalVideos: totalVideos,
            received: received,
            returned: returned,
            processed: processed
        }
        i += 1
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
