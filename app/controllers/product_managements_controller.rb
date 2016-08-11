class ProductManagementsController < ApplicationController
  before_action :set_product_management, only: [:show, :update, :destroy]

  # GET /product_managements
  # GET /product_managements.json
  def index
    @product_managements = ProductManagement.all

    render json: @product_managements
  end

  # GET /product_managements/1
  # GET /product_managements/1.json
  def show
    render json: @product_management
  end

  # POST /product_managements
  # POST /product_managements.json
  def create
    @product_management = ProductManagement.new(product_management_params)

    if @product_management.save
      render json: @product_management, status: :created, location: @product_management
    else
      render json: @product_management.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /product_managements/1
  # PATCH/PUT /product_managements/1.json
  def update
    @product_management = ProductManagement.find(params[:id])

    if @product_management.update(product_management_params)
      head :no_content
    else
      render json: @product_management.errors, status: :unprocessable_entity
    end
  end

  # DELETE /product_managements/1
  # DELETE /product_managements/1.json
  def destroy
    @product_management.destroy

    head :no_content
  end

  private

    def set_product_management
      @product_management = ProductManagement.find(params[:id])
    end

    def product_management_params
      params.require(:product_management).permit(:productionStatus, :editionStatus, :designStatus, :postProductionStatus)
    end
end
