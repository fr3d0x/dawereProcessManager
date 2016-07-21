class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :add_allow_credentials_headers
  require 'jwt'

  def add_allow_credentials_headers
    # https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#section_5
    #
    # Because we want our front-end to send cookies to allow the API to be authenticated
    # (using 'withCredentials' in the XMLHttpRequest), we need to add some headers so
    # the browser will not reject the response
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def options
    head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type'
  end

  def authenticate
    secretKey = "d@w3r3's_$3cr3t_k3y"
    authenticate_or_request_with_http_token do |token, options|
      decoded_token = JWT.decode token, secretKey, true, { :algorithm => 'HS256' }
    end
  end
end
