class QaAnalistsController < ApplicationController
  before_action :set_qa_analist, only: [:show, :update, :destroy]

  # GET /qa_analists
  # GET /qa_analists.json
  def index
    @qa_analists = QaAnalist.all

    render json: @qa_analists
  end

  # GET /qa_analists/1
  # GET /qa_analists/1.json
  def show
    render json: @qa_analist
  end

  # POST /qa_analists
  # POST /qa_analists.json
  def create
    @qa_analist = QaAnalist.new(qa_analist_params)

    if @qa_analist.save
      render json: @qa_analist, status: :created, location: @qa_analist
    else
      render json: @qa_analist.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /qa_analists/1
  # PATCH/PUT /qa_analists/1.json
  def update
    @qa_analist = QaAnalist.find(params[:id])

    if @qa_analist.update(qa_analist_params)
      head :no_content
    else
      render json: @qa_analist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /qa_analists/1
  # DELETE /qa_analists/1.json
  def destroy
    @qa_analist.destroy

    head :no_content
  end

  private

    def set_qa_analist
      @qa_analist = QaAnalist.find(params[:id])
    end

    def qa_analist_params
      params[:qa_analist]
    end
end
