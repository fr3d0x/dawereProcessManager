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

  def update_post_prod_content(vdm, newVdm)
    changes = []
    assignment= {}
    if newVdm['ppAsigned'] != nil
      if newVdm['role'] == 'postProLeader'
        assignment = vdm.post_prod_dpt.post_prod_dpt_assignment
        if assignment == nil
          assignment = PostProdDptAssignment.new
        end
        assignment.post_prod_dpt_id = vdm.post_prod_dpt.id
        assignment.user_id = newVdm['ppAsigned']['id']
        assignment.assignedName = newVdm['ppAsigned']['name']
        assignment.status = 'asignado'
        assignment.save!
        user = User.find(newVdm['ppAsigned']['id'])
        UserNotifier.send_assigned_to_post_producer(vdm, user.employee).deliver
        change = VdmChange.new
        change.changeDetail = "Asignado video a post-produccion " + newVdm['ppAsigned']['name']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.department = 'post-produccion'
        changes.push(change)
      end
    end
    if newVdm['postProdDept'] != nil
      if newVdm['postProdDept']['assignment']
        if newVdm['role'] == 'post-producer'
          if vdm.post_prod_dpt.post_prod_dpt_assignment.comments != newVdm['postProdDept']['assignment']['comments']
            change = VdmChange.new
            change.changeDetail = "Cambio de comentarios de post-productor"
            if vdm.post_prod_dpt.post_prod_dpt_assignment.comments != nil
              change.changedFrom = vdm.post_prod_dpt.post_prod_dpt_assignment.comments
            else
              change.changedFrom = "vacio"
            end
            change.changedTo = newVdm['postProdDept']['assignment']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'post-produccion'
            changes.push(change)
            vdm.post_prod_dpt.post_prod_dpt_assignment.comments = newVdm['postProdDept']['assignment']['comments']
            vdm.post_prod_dpt.post_prod_dpt_assignment.save!
          end
          if vdm.post_prod_dpt.post_prod_dpt_assignment.status != newVdm['postProdDept']['assignment']['status']
            if newVdm['postProdDept']['assignment']['status'] != 'no asignado'
              change = VdmChange.new
              change.changeDetail = "Cambio de estado de post-productor"
              if vdm.post_prod_dpt.post_prod_dpt_assignment.status != nil
                change.changedFrom = vdm.post_prod_dpt.post_prod_dpt_assignment.status
              else
                change.changedFrom = "vacio"
              end
              change.changedTo = newVdm['postProdDept']['assignment']['status']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              changes.push(change)
              vdm.post_prod_dpt.post_prod_dpt_assignment.status = newVdm['postProdDept']['assignment']['status']
              vdm.post_prod_dpt.post_prod_dpt_assignment.save!
              if vdm.post_prod_dpt.post_prod_dpt_assignment.status == 'terminado'
                UserNotifier.send_to_approved_to_post_prod_leader(vdm)
              end
            end
          end
          assignment = vdm.post_prod_dpt.post_prod_dpt_assignment
        end
      end
    end

    VdmChange.transaction do
      changes.uniq.each(&:save!)
    end
    post_prod_payload = {
        status: vdm.post_prod_dpt.status,
        comments: vdm.post_prod_dpt.comments,
        assignment: assignment
    }
    return post_prod_payload
  end
  private

  def set_post_prod_dpt
    @post_prod_dpt = PostProdDpt.find(params[:id])
  end

  def post_prod_dpt_params
    params.require(:post_prod_dpt).permit(:status, :comments)
  end
end
