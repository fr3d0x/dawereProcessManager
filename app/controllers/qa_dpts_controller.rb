class QaDptsController < ApplicationController
  before_action :set_qa_dpt, only: [:show, :update, :destroy]

  # GET /qa_dpts
  # GET /qa_dpts.json
  def index
    @qa_dpts = QaDpt.all

    render json: @qa_dpts
  end

  # GET /qa_dpts/1
  # GET /qa_dpts/1.json
  def show
    render json: @qa_dpt
  end

  # POST /qa_dpts
  # POST /qa_dpts.json
  def create
    @qa_dpt = QaDpt.new(qa_dpt_params)

    if @qa_dpt.save
      render json: @qa_dpt, status: :created, location: @qa_dpt
    else
      render json: @qa_dpt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /qa_dpts/1
  # PATCH/PUT /qa_dpts/1.json
  def update
    @qa_dpt = QaDpt.find(params[:id])

    if @qa_dpt.update(qa_dpt_params)
      head :no_content
    else
      render json: @qa_dpt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /qa_dpts/1
  # DELETE /qa_dpts/1.json
  def destroy
    @qa_dpt.destroy

    head :no_content
  end

  private

    def set_qa_dpt
      @qa_dpt = QaDpt.find(params[:id])
    end

    def qa_dpt_params
      params.require(:qa_dpt).permit(:status, :comments)
    end
end
