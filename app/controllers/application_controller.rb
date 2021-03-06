class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  require 'jwt'
  require 'json'
  $secretKey = "d@w3r3's_$3cr3t_k3y"
  $drive_copy_route = '/mnt/hgfs/NUBE DAWERE/'
  $big_files_tmp_route = '/mnt/hgfs/archivos_dpm/big_files_tmp/'
  $files_root = '/mnt/hgfs/archivos_dpm'
  def authenticate
    token = request.headers['AUTHORIZATION']
    $currentPetitionUser = JWT.decode(token, $secretKey, true, { :algorithm => 'HS256' })[0]
    rescue JWT::DecodeError
      render :json => { status: 'UNAUTHORIZED', msg: 'No Autorizado'}, :status => :unauthorized
  end

  def searchForRole(roles, userRoles)
    roleFound = false
    if roles != nil
      if roles.kind_of?(Array)
        roles.each do |role|
          userRoles.each do |userRole|
            if userRole['role'] == role
              roleFound = true
            end
          end
        end
      else
        userRoles.each do |userRole|
          if userRole['role'] == roles
            roleFound = true
          end
        end
      end
      raise Exceptions::InvalidRoleException unless roleFound
    else
      raise Exceptions::InvalidRoleException
    end
  end


  def validateRole(roles, user)
    if roles != nil
      searchForRole(roles, user['roles'])
    end
  rescue Exceptions::InvalidRoleException
    render :json => { status: 'UNAUTHORIZED', msg: 'No Autorizado'}, :status => :unauthorized
  end

  def generateVideoId(subject, vdmCount)
    videoId = (subject.grade.name[0,1] + subject.name[0, 3] +'v'+ vdmCount.to_s).upcase
    return videoId
  end



end
