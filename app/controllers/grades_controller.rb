class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :update, :destroy]

  # GET /grades
  # GET /grades.json
  def index
    @grades = Grade.all

    render json: @grades
  end

  # GET /grades/1
  # GET /grades/1.json
  def show
    render json: @grade
  end

  # POST /grades
  # POST /grades.json
  def create
    @grade = Grade.new(grade_params)

    if @grade.save
      render json: @grade, status: :created, location: @grade
    else
      render json: @grade.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /grades/1
  # PATCH/PUT /grades/1.json
  def update
    @grade = Grade.find(params[:id])

    if @grade.update(grade_params)
      head :no_content
    else
      render json: @grade.errors, status: :unprocessable_entity
    end
  end

  # DELETE /grades/1
  # DELETE /grades/1.json
  def destroy
    @grade.destroy

    head :no_content
  end

  private

    def set_grade
      @grade = Grade.find(params[:id])
    end

    def grade_params
      params.require(:grade).permit(:name, :description)
    end
end
