class PostProdDptAssignmentsController < ApplicationController
  before_action :set_post_prod_dpt_assignment, only: [:show, :update, :destroy]

  # GET /post_prod_dpt_assignments
  # GET /post_prod_dpt_assignments.json
  def index
    @post_prod_dpt_assignments = PostProdDptAssignment.all

    render json: @post_prod_dpt_assignments
  end

  # GET /post_prod_dpt_assignments/1
  # GET /post_prod_dpt_assignments/1.json
  def show
    render json: @post_prod_dpt_assignment
  end

  # POST /post_prod_dpt_assignments
  # POST /post_prod_dpt_assignments.json
  def create
    @post_prod_dpt_assignment = PostProdDptAssignment.new(post_prod_dpt_assignment_params)

    if @post_prod_dpt_assignment.save
      render json: @post_prod_dpt_assignment, status: :created, location: @post_prod_dpt_assignment
    else
      render json: @post_prod_dpt_assignment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /post_prod_dpt_assignments/1
  # PATCH/PUT /post_prod_dpt_assignments/1.json
  def update
    @post_prod_dpt_assignment = PostProdDptAssignment.find(params[:id])

    if @post_prod_dpt_assignment.update(post_prod_dpt_assignment_params)
      head :no_content
    else
      render json: @post_prod_dpt_assignment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /post_prod_dpt_assignments/1
  # DELETE /post_prod_dpt_assignments/1.json
  def destroy
    @post_prod_dpt_assignment.destroy

    head :no_content
  end

  private

    def set_post_prod_dpt_assignment
      @post_prod_dpt_assignment = PostProdDptAssignment.find(params[:id])
    end

    def post_prod_dpt_assignment_params
      params.require(:post_prod_dpt_assignment).permit(:status, :assignedName, :comments)
    end
end
