class ClassesPlanificationsController < ApplicationController
  before_action :set_classes_planification, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action {validateRole([Roles::SUPER, Roles::CONTENT_LEADER],$currentPetitionUser)}

  # GET /classes_planifications
  # GET /classes_planifications.json
  def index
    @classes_planifications = ClassesPlanification.all

    render json: @classes_planifications
  end

  # GET /classes_planifications/1
  # GET /classes_planifications/1.json
  def show
    render json: @classes_planification
  end

  # POST /classes_planifications
  # POST /classes_planifications.json
  def create
    @classes_planification = ClassesPlanification.new(classes_planification_params)

    if @classes_planification.save
      render json: @classes_planification, status: :created, location: @classes_planification
    else
      render json: @classes_planification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /classes_planifications/1
  # PATCH/PUT /classes_planifications/1.json
  def update
    @classes_planification = ClassesPlanification.find(params[:id])

    if @classes_planification.update(classes_planification_params)
      head :no_content
    else
      render json: @classes_planification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /classes_planifications/1
  # DELETE /classes_planifications/1.json
  def destroy
    @classes_planification.destroy

    head :no_content
  end

  def getClassPlan
    if params[:id] != nil
      classPlan = ClassesPlanification.find(params[:id])
      payload = {
          id: classPlan.id,
          meGeneralObjective: classPlan.meGeneralObjective,
          meSpecificObjective: classPlan.meSpecificObjective,
          topicName: classPlan.topicName,
          meSpecificObjDesc: classPlan.meSpecificObjDesc,
          videos: classPlan.videos,
          subject: classPlan.subject_planification.subject,
          vdms: classPlan.vdms.reject { |r| r.status == 'DESTROYED' }.as_json,
          changes: classPlan.cp_changes.as_json
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def saveCp
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      cp = ClassesPlanification.new
      subject = Subject.find(parameters['subjectId'])
      subjectPlan = SubjectPlanification.find(parameters['subjectPlanId'])
      vdms = []
      cp.meGeneralObjective = parameters['meGeneralObjective']
      cp.meSpecificObjective = parameters['meSpecificObjective']
      cp.meSpecificObjDesc = parameters['meSpecificObjDesc']
      cp.topicName = parameters['topicName']
      cp.subject_planification_id = parameters['subjectPlanId']
      change = CpChange.new
      change.changeDetail = 'Creacion'
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.changeDate = Time.now

      vdmCounter = 0
      lastVid = Vdm.find_by_sql('Select MAX(number) from vdms v, classes_planifications cp, subject_planifications sp where sp.subject_id = ' + subject.id.to_s + ' and cp.subject_planification_id = sp.id and v.classes_planification_id = cp.id')
      for i in 1..parameters['videos'].to_i
        vdm = Vdm.new
        if lastVid != nil
          if(vdmCounter != 0)
            vdmCounter = vdmCounter + 1
          else
            vdmCounter = lastVid.first.max + 1
          end
        else
          vdmCounter = vdmCounter + 1
        end
        vdm.videoId = generateVideoId(subject, vdmCounter)
        vdm.status = 'not received'
        vdm.number = vdmCounter
        vdms.push(vdm)
      end
      cp.save!
      change.classes_planification_id = cp.id
      change.save!
      vdms.each do |vdm|
        vdm.classes_planification_id = cp.id
      end
      Vdm.transaction do
        vdms.each(&:save!)
      end
      payload = {
          id: cp.id,
          topicName: cp.topicName,
          videos: cp.vdms.where("status != 'DESTROYED'").as_json
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end


  def editCp
    if request.raw_post != ""
      edition = ActiveSupport::JSON.decode(request.raw_post)
      cp = ClassesPlanification.find(edition['id'])
      changes = []
      if cp.meGeneralObjective != edition['meGeneralObjective']
        change = CpChange.new
        change.changeDetail = 'cambio de Onjetivo General'
        change.changedFrom = cp.meGeneralObjective
        change.changedTo = edition['meGeneralObjective']
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.classes_planification_id = cp.id
        change.topicName = cp.topicName
        change.changeDate = Time.now
        changes.push(change)
      end
      if cp.meSpecificObjective != edition['meSpecificObjective']
        change = CpChange.new
        change.changeDetail = 'cambio de Objetivo especifico'
        change.changedFrom = cp.meSpecificObjective
        change.changedTo = edition['meSpecificObjective']
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.classes_planification_id = cp.id
        change.topicName = cp.topicName
        change.changeDate = Time.now
        changes.push(change)
      end
      if cp.meSpecificObjDesc != edition['meSpecificObjDesc']
        change = CpChange.new
        change.changeDetail = 'cambio de descripcion de objetivo especifico'
        change.changedFrom = cp.meSpecificObjDesc
        change.changedTo = edition['meSpecificObjDesc']
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.classes_planification_id = cp.id
        change.topicName = cp.topicName
        change.changeDate = Time.now
        changes.push(change)
      end
      if cp.topicName != edition['topicName']
        change = CpChange.new
        change.changeDetail = 'cambio de nombre de tema'
        change.changedFrom = cp.meSpecificObjDesc
        change.changedTo = edition['meSpecificObjDesc']
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.classes_planification_id = cp.id
        change.topicName = edition['topicName']
        change.changeDate = Time.now
        changes.push(change)
      end
      cp.meGeneralObjective = edition['meGeneralObjective']
      cp.meSpecificObjective = edition['meSpecificObjective']
      cp.meSpecificObjDesc = edition['meSpecificObjDesc']
      cp.topicName = edition['topicName']
      cp.save!
      CpChange.transaction do
        changes.each(&:save!)
      end
      render :json => { data: nil, status: 'SUCCESS'}, :status => 200
    end
    rescue ActiveRecord::RecordNotFound
      render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def deleteClassPlan
    if request.raw_post != nil
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      cp = ClassesPlanification.find(parameters['id'])
      cp.status = 'DESTROYED'
      cp.save
      vdmChanges = []
      cp.vdms.each do |vdm|
        vdm.status = 'DESTROYED'
        vdmChange = VdmChange.new
        vdmChange.changeDate = Time.now
        vdmChange.changeDetail = 'Eliminacion'
        vdmChange.comments = 'Fue eliminado el plan de clases asociado a este elemento'
        vdmChange.vdm_id = vdm.id
        vdmChange.uname = $currentPetitionUser['username']
        vdmChange.videoId = vdm.videoId
        vdmChanges.push(vdmChange)
      end
      Vdm.transaction do
        cp.vdms.each(&:save!)
      end
      change = CpChange.new
      change.changeDetail = 'Eliminacion'
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.classes_planification_id = cp.id
      change.topicName = cp.topicName
      change.changeDate = Time.now
      change.save!
      VdmChange.transaction do
        vdmChanges.each(&:save!)
      end
      render :json => { data: cp, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  private

    def set_classes_planification
      @classes_planification = ClassesPlanification.find(params[:id])
    end

    def classes_planification_params
      params.require(:classes_planification).permit(:subjectPlanification_id, :meGeneralObjective, :meSpecificObjective, :meSpecificObjective, :topicName, :videos)
    end
end
