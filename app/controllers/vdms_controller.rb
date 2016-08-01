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
      lastVid = classPlan.subject_planification.classes_planifications.last.vdms.last
      if lastVid != nil
        vdmCount = lastVid.number + 1
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
        cp.vdms.each do |vdm|
          if vdm.status != 'DESTROYED'
            payload.push({
                id: vdm.id,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                cp: cp.as_json
            })
          end
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
        change.save
      end
      if vdm.videoTittle != newVdm['videoTittle']
        change = VdmChange.new
        change.changeDetail = "Cambio de Titulo"
        if vdm.videoTittle != nil
          change.changedFrom = "De "+vdm.videoTittle4
        else
          change.changedFrom = "De vacio"
        end

        change.changedTo = "A "+ newVdm['videoTittle']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.save
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
        change.save
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
        change.save
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

  private

    def set_vdm
      @vdm = Vdm.find(params[:id])
    end

    def vdm_params
      params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description)
    end
end
