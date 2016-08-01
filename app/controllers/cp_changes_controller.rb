class CpChangesController < ApplicationController
  before_action :set_cp_change, only: [:show, :update, :destroy]

  # GET /cp_changes
  # GET /cp_changes.json
  def index
    @cp_changes = CpChange.all

    render json: @cp_changes
  end

  # GET /cp_changes/1
  # GET /cp_changes/1.json
  def show
    render json: @cp_change
  end

  # POST /cp_changes
  # POST /cp_changes.json
  def create
    @cp_change = CpChange.new(cp_change_params)

    if @cp_change.save
      render json: @cp_change, status: :created, location: @cp_change
    else
      render json: @cp_change.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cp_changes/1
  # PATCH/PUT /cp_changes/1.json
  def update
    @cp_change = CpChange.find(params[:id])

    if @cp_change.update(cp_change_params)
      head :no_content
    else
      render json: @cp_change.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cp_changes/1
  # DELETE /cp_changes/1.json
  def destroy
    @cp_change.destroy

    head :no_content
  end

  def getChangesBySubject
    if params[:id] != nil
      subject = Subject.find(params[:id])
      history = CpChange.find_by_sql('Select cph.* from cp_changes cph, classes_planifications cp, subject_planifications sp where sp.subject_id =' + params[:id] + ' and cp.subject_planification_id = sp.id and cph.classes_planification_id = cp.id')
      payload = {
          subject: subject,
          history: history.as_json
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  private

    def set_cp_change
      @cp_change = CpChange.find(params[:id])
    end

    def cp_change_params
      params.require(:cp_change).permit(:changeDate, :changeDetail, :changedFrom, :changedTo, :comments, :uname)
    end
end
