class PostProdDptsController < ApplicationController
  before_action :set_post_prod_dpt, only: [:show, :update, :destroy]

  # GET /post_prod_dpts
  # GET /post_prod_dpts.json
  def index
    @post_prod_dpts = PostProdDpt.all

    render json: @post_prod_dpts
  end

  # GET /post_prod_dpts/1
  # GET /post_prod_dpts/1.json
  def show
    render json: @post_prod_dpt
  end

  # POST /post_prod_dpts
  # POST /post_prod_dpts.json
  def create
    @post_prod_dpt = PostProdDpt.new(post_prod_dpt_params)

    if @post_prod_dpt.save
      render json: @post_prod_dpt, status: :created, location: @post_prod_dpt
    else
      render json: @post_prod_dpt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /post_prod_dpts/1
  # PATCH/PUT /post_prod_dpts/1.json
  def update
    @post_prod_dpt = PostProdDpt.find(params[:id])

    if @post_prod_dpt.update(post_prod_dpt_params)
      head :no_content
    else
      render json: @post_prod_dpt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /post_prod_dpts/1
  # DELETE /post_prod_dpts/1.json
  def destroy
    @post_prod_dpt.destroy

    head :no_content
  end

  private

    def set_post_prod_dpt
      @post_prod_dpt = PostProdDpt.find(params[:id])
    end

    def post_prod_dpt_params
      params.require(:post_prod_dpt).permit(:status, :comments)
    end
end
