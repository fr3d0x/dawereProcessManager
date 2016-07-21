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
    parameters = ActiveSupport::JSON.decode(request.raw_post)
    user = User.find_by_username(parameters["username"])
    if user
      if user.password == parameters["password"]
        secretKey = "d@w3r3's_$3cr3t_k3y"
        payload = {
            username: user.username,
            password: user.password
        }
        token = JWT.encode(payload, secretKey, "HS256")
        render :json => { data: token, status: "AUTHORIZED"}
      else
        render :json => { data: "el password del usuario no es correcto"}
      end
    else
      render :json => { data: "usuario no encontrado"}
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
