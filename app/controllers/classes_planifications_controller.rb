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
          vdms: classPlan.vdms.as_json
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def editCp
    if params[:id] && request.raw_post != ""
      edition = ActiveSupport::JSON.decode(request.raw_post)
      cp = ClassesPlanification.find(params[:id])



    end
  end
  private

    def set_classes_planification
      @classes_planification = ClassesPlanification.find(params[:id])
    end

    def classes_planification_params
      params.require(:classes_planification).permit(:subjectPlanification_id, :meGeneralObjective, :meSpecificObjective, :meSpecificObjective, :topicName, :videos)
    end
end
