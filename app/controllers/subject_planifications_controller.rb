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
      subject_planification = SubjectPlanification.find(params[:id])
      payload = {
          id: subject_planification.id,
          status: subject_planification.status,
          subject: subject_planification.subject,
          classesPlaning: subject_planification.classes_planifications.as_json
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
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
