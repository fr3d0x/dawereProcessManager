class ProductionDptsController < ApplicationController
  before_action :set_production_dpt, only: [:show, :update, :destroy]

  # GET /production_dpts
  # GET /production_dpts.json
  def index
    @production_dpts = ProductionDpt.all

    render json: @production_dpts
  end

  # GET /production_dpts/1
  # GET /production_dpts/1.json
  def show
    render json: @production_dpt
  end

  # POST /production_dpts
  # POST /production_dpts.json
  def create
    @production_dpt = ProductionDpt.new(production_dpt_params)

    if @production_dpt.save
      render json: @production_dpt, status: :created, location: @production_dpt
    else
      render json: @production_dpt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /production_dpts/1
  # PATCH/PUT /production_dpts/1.json
  def update
    @production_dpt = ProductionDpt.find(params[:id])

    if @production_dpt.update(production_dpt_params)
      head :no_content
    else
      render json: @production_dpt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /production_dpts/1
  # DELETE /production_dpts/1.json
  def destroy
    @production_dpt.destroy

    head :no_content
  end

  private

    def set_production_dpt
      @production_dpt = ProductionDpt.find(params[:id])
    end

    def production_dpt_params
      params.require(:production_dpt).permit(:status, :script, :comments, :intro, :vidDev, :conclu)
    end
end
