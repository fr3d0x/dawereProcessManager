class VdmsController < ApplicationController
  before_action :set_vdm, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :only => [:addVdm] {validateRole([Roles::SUPER, Roles::CONTENT_LEADER],$currentPetitionUser)}
  include ActionView::Helpers::TextHelper

  # GET /vdms
  # GET /vdms.json
  def index
    @vdms = Vdm.all

    render json: @vdms
  end

  # GET /vdms/1
  # GET /vdms/1.json
  def show
    render json: @vdm
  end

  # POST /vdms
  # POST /vdms.json
  def create
    @vdm = Vdm.new(vdm_params)

    if @vdm.save
      render json: @vdm, status: :created, location: @vdm
    else
      render json: @vdm.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vdms/1
  # PATCH/PUT /vdms/1.json
  def update
    @vdm = Vdm.find(params[:id])

    if @vdm.update(vdm_params)
      head :no_content
    else
      render json: @vdm.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vdms/1
  # DELETE /vdms/1.json
  def destroy
    @vdm.destroy

    head :no_content
  end

  def deleteVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.find(params[:id])
      vdm.status = 'DESTROYED'
      vdm.save
      change = VdmChange.new
      change.changeDetail = "Eliminacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def addVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.new
      classPlan = ClassesPlanification.find(parameters['cp']['id'])
      subject = Subject.find(classPlan.subject_planification.subject_id)
      vdm.status = parameters['status']
      vdm.classes_planification_id = parameters['cp']['id']
      vdm.comments = parameters['comments']
      vdm.videoContent = parameters['videoContent']
      vdm.videoTittle = parameters['videoTittle']
      lastVid = Vdm.find_by_sql('Select MAX(number) from vdms v, classes_planifications cp, subject_planifications sp where sp.subject_id = ' + subject.id.to_s + ' and cp.subject_planification_id = sp.id and v.classes_planification_id = cp.id')
      if lastVid != nil
        vdmCount = lastVid.first.max + 1
      else
        vdmCount = 1
      end
      vdm.videoId = generateVideoId(subject, vdmCount)
      vdm.number = vdmCount
      vdm.save!
      change = VdmChange.new
      change.changeDetail = "Creacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def getVdmsBySubject
    if params[:id] != nil
      sp = SubjectPlanification.find_by_subject_id(params[:id])
      i = 0
      payload = []
      sp.classes_planifications.each do |cp|
        cp.vdms.reject{ |r| r.status == 'DESTROYED' }.each do |vdm|
          payload.push({
              id: vdm.id,
              videoId: vdm.videoId,
              videoTittle: vdm.videoTittle,
              videoContent: vdm.videoContent,
              status: vdm.status,
              comments: vdm.comments,
              cp: cp.as_json,
              prodDept: vdm.production_dpt
          })
          i+=1
        end
      end
      render :json => { data: payload, subject: sp.subject, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def getWholeVdm
    if params[:id] != nil
      vdm = Vdm.find(params[:id])

      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          subject: vdm.classes_planification.subject_planification.subject,
          changes: vdm.vdm_changes
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def updateVdm
    if request.raw_post != nil
      newVdm = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.find(newVdm['id'])
      changes = [];
      if vdm.videoContent != newVdm['videoContent']
        change = VdmChange.new
        change.changeDetail = "Cambio de contenido"
        if vdm.videoContent != nil
          change.changedFrom = "De "+vdm.videoContent
        else
          change.changedFrom = "De vacio"
        end
        change.changedTo = "A "+ newVdm['videoContent']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        changes.push(change)
      end
      if vdm.videoTittle != newVdm['videoTittle']
        change = VdmChange.new
        change.changeDetail = "Cambio de Titulo"
        if vdm.videoTittle != nil
          change.changedFrom = "De "+vdm.videoTittle
        else
          change.changedFrom = "De vacio"
        end

        change.changedTo = "A "+ newVdm['videoTittle']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        changes.push(change)
      end
      if vdm.status != newVdm['status']
        change = VdmChange.new
        change.changeDetail = "Cambio de estado"
        change.changedFrom = "De "+vdm.status
        change.changedTo = "A "+ newVdm['status']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        changes.push(change)
      end
      if vdm.comments != newVdm['comments']
        change = VdmChange.new
        change.changeDetail = "Cambio de comentarios"
        if vdm.videoTittle != nil
          change.changedFrom = "De "+vdm.comments
        else
          change.changedFrom = "De vacio"
        end
        change.changedTo = "A "+ newVdm['comments']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        changes.push(change)
      end
      VdmChange.transaction do
        changes.each(&:save!)
      end
      if newVdm['prodDept'] != nil
        prodDeptChanges = []
        if vdm.production_dpt != nil
          if vdm.production_dpt.comments != newVdm['prodDept']['comments']
            change = VdmChange.new
            change.changeDetail = "Cambio de comentarios de produccion"
            if vdm.production_dpt.comments != nil
              change.changedFrom = "De "+vdm.production_dpt.comments
            else
              change.changedFrom = "De vacio"
            end
            change.changedTo = "A "+ newVdm['prodDept']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end

          if vdm.production_dpt.script != newVdm['prodDept']['script']
            change = VdmChange.new
            change.changeDetail = "Cambio de Guion de produccion"
            if vdm.production_dpt.comments != nil
              change.changedFrom = "De "+vdm.production_dpt.script
            else
              change.changedFrom = "De vacio"
            end
            change.changedTo = "A "+ newVdm['prodDept']['script']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] != vdm.production_dpt.intro && newVdm['prodDept']['conclu'] != vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "Grabacion completa"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.comments = 'Se grabo el video completo'
            change.changeDate = Time.now
            vdm.production_dpt.status = 'recorded'
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] != vdm.production_dpt.intro && newVdm['prodDept']['conclu'] != vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro y conclucion"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] != vdm.production_dpt.intro && newVdm['prodDept']['conclu'] == vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro y desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] == vdm.production_dpt.intro && newVdm['prodDept']['conclu'] != vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo conclusion y desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] == vdm.production_dpt.intro && newVdm['prodDept']['conclu'] == vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] != vdm.production_dpt.intro && newVdm['prodDept']['conclu'] == vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] == vdm.production_dpt.intro && newVdm['prodDept']['conclu'] != vdm.production_dpt.conclu && newVdm['prodDept']['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo conclusion"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            prodDeptChanges.push(change)
          end
          if newVdm['prodDept']['intro'] == true && newVdm['prodDept']['conclu'] == true && newVdm['prodDept']['vidDev'] == true
            change = VdmChange.new
            change.changeDetail = "Grabacion completa"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.comments = 'Se grabo el video completo'
            change.changeDate = Time.now
            vdm.production_dpt.status = 'recorded'
            prodDeptChanges.push(change)
          end
          vdm.production_dpt.comments = newVdm['prodDept']['comments']
          vdm.production_dpt.script = newVdm['prodDept']['script']
          vdm.production_dpt.intro = newVdm['prodDept']['intro']
          vdm.production_dpt.conclu = newVdm['prodDept']['conclu']
          vdm.production_dpt.vidDev = newVdm['prodDept']['vidDev']
          vdm.production_dpt.save!
          VdmChange.transaction do
            prodDeptChanges.uniq.each(&:save!)
          end
        end
      end
      vdm.videoContent = newVdm['videoContent']
      vdm.videoTittle = newVdm['videoTittle']
      vdm.status = newVdm['status']
      vdm.comments = newVdm['comments']
      vdm.save
      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          subject: vdm.classes_planification.subject_planification.subject
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def getDawereVdms

    sp = SubjectPlanification.find_by_subject_id(100)
    i = 0
    payload = []
    sp.classes_planifications.each do |cp|
      cp.vdms.reject{ |r| r.status == 'DESTROYED' }.each do |vdm|
        payload.push({
           id: vdm.id,
           videoId: vdm.videoId,
           videoTittle: vdm.videoTittle,
           videoContent: vdm.videoContent,
           status: vdm.status,
           comments: vdm.comments,
           cp: cp.as_json,
           prodDpt: vdm.production_dpt
        })
        i+=1
      end
    end
    render :json => { data: payload, subject: sp.subject, status: 'SUCCESS'}, :status => 200
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def addDawereVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.new
      classPlan = ClassesPlanification.find(1000)
      subject = Subject.find(classPlan.subject_planification.subject_id)
      vdm.status = parameters['status']
      vdm.classes_planification_id = parameters['cp']['id']
      vdm.comments = parameters['comments']
      vdm.videoContent = parameters['videoContent']
      vdm.videoTittle = parameters['videoTittle']
      lastVid = Vdm.find_by_sql('Select MAX(number) from vdms v, classes_planifications cp, subject_planifications sp where sp.subject_id = ' + subject.id.to_s + ' and cp.subject_planification_id = sp.id and v.classes_planification_id = cp.id')
      if lastVid != nil
        vdmCount = lastVid.first.max + 1
      else
        vdmCount = 1
      end
      vdm.videoId = generateVideoId(subject, vdmCount)
      vdm.number = vdmCount
      vdm.save!
      change = VdmChange.new
      change.changeDetail = "Creacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  private

    def set_vdm
      @vdm = Vdm.find(params[:id])
    end

    def vdm_params
      params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description)
    end
end
