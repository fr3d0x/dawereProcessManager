class SubjectPlanificationsController < ApplicationController
  before_action :set_subject_planification, only: [:show, :update, :destroy]
  before_action :authenticate

  # GET /subject_planifications
  # GET /subject_planifications.json
  def index
    @subject_planifications = SubjectPlanification.all

    render json: @subject_planifications
  end

  # GET /subject_planifications/1
  # GET /subject_planifications/1.json
  def show
    render json: @subject_planification
  end

  # POST /subject_planifications
  # POST /subject_planifications.json
  def create
    @subject_planification = SubjectPlanification.new(subject_planification_params)

    if @subject_planification.save
      render json: @subject_planification, status: :created, location: @subject_planification
    else
      render json: @subject_planification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subject_planifications/1
  # PATCH/PUT /subject_planifications/1.json
  def update
    @subject_planification = SubjectPlanification.find(params[:id])

    if @subject_planification.update(subject_planification_params)
      head :no_content
    else
      render json: @subject_planification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subject_planifications/1
  # DELETE /subject_planifications/1.json
  def destroy
    @subject_planification.destroy

    head :no_content
  end

  def getSubjectsPlanning
    if $currentPetitionUser['id'] != nil
      subjectPlanings = SubjectPlanification.where(:user_id => $currentPetitionUser['id'])
      i = 0
      payload = []
      subjectPlanings.each do |sp|
        payload[i] = {
            teacher: sp.teacher,
            subject: sp.subject,
            status: sp.status
        }
        i += 1
      end
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  end

  def getWholeSubjectPlanning
    if params[:id] != nil
      payload = nil
      subject_planification = SubjectPlanification.find_by_subject_id(params[:id])
      subject = Subject.find(params[:id])
      if subject_planification != nil
        cps = []
        subject_planification.classes_planifications.reject { |r| r.status == 'DESTROYED' }.each do |classPlan|
          cp = {
              id: classPlan.id,
              meGeneralObjective: classPlan.meGeneralObjective,
              meSpecificObjective: classPlan.meSpecificObjective,
              meSpecificObjDesc: classPlan.meSpecificObjDesc,
              topicName: classPlan.topicName,
              topicNumber: classPlan.topicNumber,
              period: classPlan.period,
              vdms: classPlan.vdms.reject { |r| r.status == 'DESTROYED' }.as_json,
              vdmsString: classPlan.vdms.reject { |r| r.status == 'DESTROYED' }.as_json.to_s

          }
          cps.push(cp)
        end
        payload = {
            id: subject_planification.id,
            status: subject_planification.status,
            subject: subject_planification.subject,
            classesPlaning: cps
        }
      end
      render :json => { data: payload, subject: subject, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def saveSubjectPlanning
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      subject = Subject.find(parameters['subjectId'])
      teacher = Teacher.new
      subjectPlan = SubjectPlanification.new
      cps = []
      vdms = []
      teacher.firstName = parameters['teacher']['firstName']
      teacher.middleName = parameters['teacher']['middleName']
      teacher.lastName = parameters['teacher']['lastName']
      teacher.personalId = parameters['teacher']['personalId']
      teacher.cvLong = parameters['teacher']['cvLong']
      teacher.cvShort = parameters['teacher']['cvShort']
      teacher.save!
      subjectPlan.status = 'active'
      subjectPlan.teacher_id = teacher.id
      subjectPlan.subject_id = parameters['subjectId']
      subjectPlan.firstPeriodCompleted = false
      subjectPlan.save!
      array = parameters['cps']
      for i in 0..array.count - 1
        cp = ClassesPlanification.new
        cp.meGeneralObjective = array[i]['meGeneralObjective']
        cp.meSpecificObjective = array[i]['meSpecificObjective']
        cp.meSpecificObjDesc = array[i]['meSpecificObjDesc']
        cp.topicName = array[i]['topicName']
        cp.videos = array[i]['videos']
        cp.period = array[i]['period']
        cp.subject_planification_id = subjectPlan.id
        cp.topicNumber = i + 1
        cps.push(cp)
      end
      ClassesPlanification.transaction do
        cps.each(&:save!)
      end

      vdmCounter = 0
      cps.each do |cp|
        for i in 1..cp.videos.to_i
          vdm = Vdm.new
          vdm.classes_planification_id = cp.id
          vdmCounter = vdmCounter + 1
          vdm.videoId = generateVideoId(subject, vdmCounter)
          vdm.status = 'no recibido'
          vdm.number = vdmCounter
          vdms.push(vdm)
        end
      end
      Vdm.transaction do
        vdms.each(&:save!)
      end
      render :json => { data: nil, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  private

    def set_subject_planification
      @subject_planification = SubjectPlanification.find(params[:id])
    end

    def subject_planification_params
      params.require(:subject_planification).permit(:subjectId, :teacherId, :status)
    end
end
