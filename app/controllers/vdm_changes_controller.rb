class VdmChangesController < ApplicationController
  before_action :set_vdm_change, only: [:show, :update, :destroy]

  # GET /vdm_changes
  # GET /vdm_changes.json
  def index
    @vdm_changes = VdmChange.all

    render json: @vdm_changes
  end

  # GET /vdm_changes/1
  # GET /vdm_changes/1.json
  def show
    render json: @vdm_change
  end

  # POST /vdm_changes
  # POST /vdm_changes.json
  def create
    @vdm_change = VdmChange.new(vdm_change_params)

    if @vdm_change.save
      render json: @vdm_change, status: :created, location: @vdm_change
    else
      render json: @vdm_change.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vdm_changes/1
  # PATCH/PUT /vdm_changes/1.json
  def update
    @vdm_change = VdmChange.find(params[:id])

    if @vdm_change.update(vdm_change_params)
      head :no_content
    else
      render json: @vdm_change.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vdm_changes/1
  # DELETE /vdm_changes/1.json
  def destroy
    @vdm_change.destroy

    head :no_content
  end

  private

    def set_vdm_change
      @vdm_change = VdmChange.find(params[:id])
    end

    def vdm_change_params
      params.require(:vdm_change).permit(:changeDate, :changeDetail, :changedFrom, :changedTo)
    end
end
