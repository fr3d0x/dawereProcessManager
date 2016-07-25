class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  require 'jwt'
  $secretKey = "d@w3r3's_$3cr3t_k3y"


  def authenticate
    token = request.headers["AUTHORIZATION"]
    JWT.decode(token, $secretKey, true, { :algorithm => 'HS256' })
    rescue JWT::DecodeError
      render :json => { status: "UNAUTHORIZED", msg: "No Autorizado"}, :status => :unauthorized
  end
end
