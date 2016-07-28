class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]

  # GET /subjects
  # GET /subjects.json
  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def getSubjectByGrade
    if (params[:id]) != nil
      @subjects = Subject.where(:grade_id => params[:id])
      render json: {data: @subjects, status: "SUCCESS"}, :status => 200
    end
    rescue
      render json: {status: "NOT FOUND", msg: "No existe ID de Grado seleccionado"}, :status => 404
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    render json: @subject
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      render json: @subject, status: :created, location: @subject
    else
      render json: @subject.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subjects/1
  # PATCH/PUT /subjects/1.json
  def update
    @subject = Subject.find(params[:id])

    if @subject.update(subject_params)
      head :no_content
    else
      render json: @subject.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy

    head :no_content
  end

  private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params.require(:subject).permit(:name, :shortDescription, :longDescription, :grade, :firstPeriodDesc, :secondPeriodDesc, :thirdPeriodDesc, :goal)
    end
end
