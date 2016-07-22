class SubjectPlanificationsController < ApplicationController
  before_action :set_subject_planification, only: [:show, :update, :destroy]

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

  private

    def set_subject_planification
      @subject_planification = SubjectPlanification.find(params[:id])
    end

    def subject_planification_params
      params.require(:subject_planification).permit(:subjectId, :teacherId, :status)
    end
end
