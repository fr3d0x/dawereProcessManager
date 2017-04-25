class ProductionDptsController < ApplicationController
  before_action :set_production_dpt, only: [:show, :update, :destroy]

  # GET /production_dpts
  # GET /production_dpts.json
  def index
    @production_dpts = ProductionDpt.all

    render json: @production_dpts
  end

  # GET /production_dpts/1
  # GET /production_dpts/1.json
  def show
    render json: @production_dpt
  end

  # POST /production_dpts
  # POST /production_dpts.json
  def create
    @production_dpt = ProductionDpt.new(production_dpt_params)

    if @production_dpt.save
      render json: @production_dpt, status: :created, location: @production_dpt
    else
      render json: @production_dpt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /production_dpts/1
  # PATCH/PUT /production_dpts/1.json
  def update
    @production_dpt = ProductionDpt.find(params[:id])

    if @production_dpt.update(production_dpt_params)
      head :no_content
    else
      render json: @production_dpt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /production_dpts/1
  # DELETE /production_dpts/1.json
  def destroy
    @production_dpt.destroy

    head :no_content
  end

  def self.update_production_content(vdm, newVdm)
    changes = []
    assignment = nil
    if vdm.production_dpt != nil
      if newVdm['prodDept'] != nil
        if newVdm['role'] == 'production'
          if vdm.production_dpt.comments != newVdm['prodDept']['comments']
            change = VdmChange.new
            change.changeDetail = 'Cambio de comentarios de produccion'
            if vdm.production_dpt.comments != nil
              change.changedFrom = vdm.production_dpt.comments
            else
              change.changedFrom = 'vacio'
            end
            change.changedTo = newVdm['prodDept']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
          end


          if newVdm['script'] != nil
            change = VdmChange.new
            change.changeDetail = 'Cambio de libreto de produccion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            vdm.production_dpt.script_name = newVdm['script']['filename']

            vdm.production_dpt.script = newVdm['script']['base64']
            change.changedTo = vdm.production_dpt.script.url
            change.department = 'produccion'
            changes.push(change)

          end


          if newVdm['screen_play'] != nil
            change = VdmChange.new
            change.changeDetail = 'Cambio de Guion de produccion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            vdm.production_dpt.screen_play_name = newVdm['screen_play']['filename']

            vdm.production_dpt.screen_play = newVdm['screen_play']['base64']
            change.changedTo = vdm.production_dpt.screen_play.url

            change.department = 'produccion'
            changes.push(change)

          end


          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'Grabacion completa'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.comments = 'Se grabo el video completo'
            change.changeDate = Time.now
            change.department = 'produccion'
            vdm.production_dpt.status = 'grabado'
            if vdm.production_dpt.production_dpt_assignment == nil || vdm.production_dpt.production_dpt_assignment.user_id == nil
              user = VdmsController.assign_task_to('editor')
              assignment = ProductionDptAssignment.new
              assignment.production_dpt_id = vdm.production_dpt.id
              assignment.status = 'asignado'
              assignment.user_id = user.id
              assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
              assignment.save!
              UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
            end
            if vdm.product_management != nil
              vdm.product_management.productionStatus = 'por aprobar'
              vdm.product_management.save!
            else
              management = ProductManagement.new
              management.productionStatus = 'por aprobar'
              management.vdm_id = vdm.id
              management.save!
            end
            changes.push(change)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro y conclucion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro y desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo conclusion y desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo conclusion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)
          end
          if newVdm['prodDept']['assigned'] != nil || newVdm['assignedId'] != nil
            if newVdm['assignedId'] != nil
              user = User.find(newVdm['assignedId'])
            else
              user = User.find(newVdm['prodDept']['assigned']['id'])
            end
            if vdm.production_dpt.production_dpt_assignment == nil
              vdm.production_dpt.production_dpt_assignment = ProductionDptAssignment.new
            end
            vdm.production_dpt.production_dpt_assignment.user_id = user.id
            vdm.production_dpt.production_dpt_assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
            vdm.production_dpt.production_dpt_assignment.status = 'asignado'
            vdm.production_dpt.production_dpt_assignment.save!
            UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
          end
          vdm.production_dpt.intro = newVdm['intro']
          vdm.production_dpt.conclu = newVdm['conclu']
          vdm.production_dpt.vidDev = newVdm['vidDev']
          vdm.production_dpt.comments = newVdm['prodDept']['comments']
          vdm.production_dpt.save!
        end
      end

      if newVdm['prodDept']['assignment'] != nil
        if newVdm['role'] == 'editor'
          if vdm.production_dpt.production_dpt_assignment.comments != newVdm['prodDept']['assignment']['comments']
            change = VdmChange.new
            change.changeDetail = 'Cambio de comentarios de editor'
            if vdm.production_dpt.production_dpt_assignment.comments != nil
              change.changedFrom = vdm.production_dpt.production_dpt_assignment.comments
            else
              change.changedFrom = 'vacio'
            end
            change.changedTo = newVdm['prodDept']['assignment']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'edicion'
            changes.push(change)
          end
          if vdm.production_dpt.production_dpt_assignment.status != newVdm['prodDept']['assignment']['status']
            if newVdm['prodDept']['assignment']['status'] != 'no asignado'
              change = VdmChange.new
              change.changeDetail = 'Cambio de estado de editor'
              if vdm.production_dpt.production_dpt_assignment.status != nil
                change.changedFrom = vdm.production_dpt.production_dpt_assignment.status
              else
                change.changedFrom = 'vacio'
              end
              change.changedTo = newVdm['prodDept']['assignment']['status']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'edicion'
              changes.push(change)
            end
          end
          if newVdm['videoClip']
            change = VdmChange.new
            change.changeDetail = 'Cambio de video clip de editor'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'edicion'
            vdm.production_dpt.production_dpt_assignment.video_clip_name = newVdm['videoClip']['filename']
            vdm.production_dpt.production_dpt_assignment.video_clip = newVdm['videoClip']['base64']
            change.changedTo = vdm.production_dpt.production_dpt_assignment.video_clip.url

            changes.push(change)
          end
          if newVdm['premierProject']
            change = VdmChange.new
            change.changeDetail = 'Cambio de proyecto premier de editor'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'edicion'
            vdm.production_dpt.production_dpt_assignment.premier_project_name = newVdm['premierProject']['filename']
            vdm.production_dpt.production_dpt_assignment.premier_project = newVdm['premierProject']['base64']
            change.changedTo = vdm.production_dpt.production_dpt_assignment.premier_project.url

            changes.push(change)
          end
          vdm.production_dpt.production_dpt_assignment.comments = newVdm['prodDept']['assignment']['comments']
          if newVdm['prodDept']['assignment']['status'] != 'no asignado'
            vdm.production_dpt.production_dpt_assignment.status = newVdm['prodDept']['assignment']['status']
          end
          vdm.production_dpt.production_dpt_assignment.save!
          if vdm.production_dpt.production_dpt_assignment.status == 'editado'
            UserNotifier.send_to_approved_to_production(vdm).deliver
          end
        end
      end
      VdmChange.transaction do
        changes.uniq.each(&:save!)
      end
    end
    if assignment == nil
      assignment = vdm.production_dpt.production_dpt_assignment
    end
    prd_payload = {
        status: vdm.production_dpt.status,
        script: vdm.production_dpt.script,
        screen_play: vdm.production_dpt.screen_play,
        script_name: vdm.production_dpt.script_name,
        screen_play_name: vdm.production_dpt.screen_play_name,
        comments: vdm.production_dpt.comments,
        intro: vdm.production_dpt.intro,
        conclu: vdm.production_dpt.conclu,
        vidDev: vdm.production_dpt.vidDev,
        assignment: assignment
    }
    return prd_payload
  end

  def self.checkForCompleteRecording(intro, vidDev, conclu, vdm, array)
    if intro == true && conclu == true && vidDev == true
      change = VdmChange.new
      change.changeDetail = 'Grabacion completa'
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.comments = 'Se grabo el video completo'
      change.changeDate = Time.now
      change.department = 'produccion'
      vdm.production_dpt.status = 'grabado'
      user = VdmsController.assign_task_to('editor')
      if vdm.production_dpt.production_dpt_assignment == nil || vdm.production_dpt.production_dpt_assignment.user_id == nil
        assignment = ProductionDptAssignment.new
        assignment.production_dpt_id = vdm.production_dpt.id
        assignment.status = 'asignado'
        assignment.user_id = user.id
        assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
        assignment.save!
        UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
      end
      if vdm.product_management != nil
        vdm.product_management.productionStatus = 'por aprobar'
        vdm.product_management.save!
      else
        management = ProductManagement.new
        management.productionStatus = 'por aprobar'
        management.vdm_id = vdm.id
        management.save!
      end
      array.push(change)
    end
  end

  private

  def set_production_dpt
    @production_dpt = ProductionDpt.find(params[:id])
  end

  def production_dpt_params
    params.require(:production_dpt).permit(:status, :script, :comments, :intro, :vidDev, :conclu)
  end
end