class VdmsController < ApplicationController
  before_action :set_vdm, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :only => [:addVdm, :deleteVdm] {validateRole([Roles::SUPER, Roles::CONTENT_LEADER],$currentPetitionUser)}
  include ActionView::Helpers::TextHelper
  require 'fileutils'

  # GET /vdms
  # GET /vdms.json
  def index
    @vdms = Vdm.all

    render json: @vdms
  end

  # GET /vdms/1
  # GET /vdms/1.json
  def show
    render json: @vdm
  end

  # POST /vdms
  # POST /vdms.json
  def create
    @vdm = Vdm.new(vdm_params)

    if @vdm.save
      render json: @vdm, status: :created, location: @vdm
    else
      render json: @vdm.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vdms/1
  # PATCH/PUT /vdms/1.json
  def update
    @vdm = Vdm.find(params[:id])

    if @vdm.update(vdm_params)
      head :no_content
    else
      render json: @vdm.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vdms/1
  # DELETE /vdms/1.json
  def destroy
    @vdm.destroy

    head :no_content
  end

  def deleteVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.find(params[:id])
      vdm.status = 'DESTROYED'
      vdm.save
      change = VdmChange.new
      change.changeDetail = "Eliminacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.department = 'pre-produccion'
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def addVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.new
      classPlan = ClassesPlanification.find(parameters['cp']['id'])
      subject = Subject.find(classPlan.subject_planification.subject_id)
      vdm.status = parameters['status']
      vdm.classes_planification_id = parameters['cp']['id']
      vdm.comments = parameters['comments']
      vdm.videoContent = parameters['videoContent']
      vdm.videoTittle = parameters['videoTittle']
      lastVid = Vdm.find_by_sql('Select MAX(number) from vdms v, classes_planifications cp, subject_planifications sp where sp.subject_id = ' + subject.id.to_s + ' and cp.subject_planification_id = sp.id and v.classes_planification_id = cp.id')
      if lastVid != nil
        vdmCount = lastVid.first['MAX(number)'] + 1
      else
        vdmCount = 1
      end
      vdm.videoId = generateVideoId(subject, vdmCount)
      vdm.number = vdmCount
      vdm.save!
      change = VdmChange.new
      change.changeDetail = "Creacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.department = 'pre-produccion'
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      if parameters['role'] == 'contentLeader'
        if vdm.status == 'procesado'
          if classPlan.subject_planification.firstPeriodCompleted == true
            production_dpt = vdm.production_dpt
            if production_dpt == nil
              production_dpt = ProductionDpt.new
            end
            production_dpt.status = 'asignado'
            production_dpt.vdm_id = vdm['id']
            production_dpt.save!
            UserNotifier.send_assigned_to_production(vdm).deliver
          end
        end
      end

      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def getVdmsBySubject
    if params[:id] != nil
      sp = SubjectPlanification.find_by_subject_id(params[:id])
      role = params[:role]
      subject = Subject.find(params[:id])
      payload = nil
      employees = []
      if sp != nil
        payload = []
        sp.classes_planifications.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |cp|
          cp.vdms.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |vdm|
            status = vdm.status
            payload_item = {
                id: vdm.id,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: status,
                comments: vdm.comments,
                vdm_type: vdm.vdm_type,
                cp: cp.as_json,
                cpId: cp.id,
                videoNumber: vdm.number,
                topicNumber: cp.topicNumber,
                classDoc: vdm.classDoc,
                class_doc_name: vdm.class_doc_name,
                teacherFiles: vdm.teacher_files,
                topicName: cp.topicName
            }
            case role
              when 'contentLeader', 'contentAnalist'
                payload_item['prodDept'] = vdm.production_dpt
              when 'production', 'editor'
                responsable = 'sin editor'
                payload_item['status'] = 'no asignado'
                if vdm.production_dpt != nil
                  if role == 'production'
                    if vdm.production_dpt.status != nil && vdm.production_dpt.status != ''
                      payload_item['status']  = vdm.production_dpt.status
                    end
                  else
                    if vdm.production_dpt.production_dpt_assignment != nil
                      payload_item['status']  = vdm.production_dpt.production_dpt_assignment.status
                    end
                  end
                  production_dpt = {
                      id: vdm.production_dpt.id,
                      status: vdm.production_dpt.status,
                      script: vdm.production_dpt.script,
                      comments: vdm.production_dpt.comments,
                      intro: vdm.production_dpt.intro,
                      vidDev: vdm.production_dpt.vidDev,
                      conclu: vdm.production_dpt.conclu,
                      screen_play: vdm.production_dpt.screen_play,
                      script_name: vdm.production_dpt.script_name,
                      screen_play_name: vdm.production_dpt.screen_play_name,
                      master_planes: vdm.production_dpt.master_planes,
                      detail_planes: vdm.production_dpt.detail_planes,
                      wacom_vids: vdm.production_dpt.wacom_vids,
                      prod_audios: vdm.production_dpt.prod_audios,
                  }
                  if vdm.production_dpt.production_dpt_assignment != nil
                    responsable = vdm.production_dpt.production_dpt_assignment.assignedName
                    production_dpt['assignment'] = vdm.production_dpt.production_dpt_assignment
                  end
                  payload_item['intro'] = vdm.production_dpt.intro
                  payload_item['conclu'] = vdm.production_dpt.conclu
                  payload_item['vidDev'] = vdm.production_dpt.vidDev
                  payload_item['prodDeptStatus'] = vdm.production_dpt.status
                  payload_item['prodDept'] = production_dpt
                end
                payload_item['responsable'] = responsable
              when 'designLeader', 'designer'
                if vdm.design_dpt != nil
                  design_dpt = {
                      id: vdm.design_dpt.id,
                      status: vdm.design_dpt.status,
                      comments: vdm.design_dpt.comments,
                  }
                  if vdm.design_dpt.design_assignment != nil
                    assignment = {
                        id: vdm.design_dpt.design_assignment.id,
                        status: vdm.design_dpt.design_assignment.status,
                        assignedName: vdm.design_dpt.design_assignment.assignedName,
                        comments: vdm.design_dpt.design_assignment.comments,
                        user_id: vdm.design_dpt.design_assignment.user_id,
                        design_jpgs: vdm.design_dpt.design_assignment.design_jpgs,
                        design_ilustrators: vdm.design_dpt.design_assignment.design_ilustrators,
                        designed_presentation: vdm.design_dpt.design_assignment.designed_presentation,
                        designed_presentation_name: vdm.design_dpt.design_assignment.designed_presentation_name,
                        design_elements: vdm.design_dpt.design_assignment.design_elements
                    }
                    design_dpt['assignment'] = assignment
                  end
                  payload_item['prodDept'] = vdm.production_dpt
                  payload_item['designDept'] = design_dpt
                end
              when 'postProLeader', 'post-producer'
                responsable = 'sin post-productor'
                payload_item['status'] = 'no asignado'
                if vdm.post_prod_dpt != nil
                  post_prod_dpt = {
                      id: vdm.post_prod_dpt.id,
                      status: vdm.post_prod_dpt.status,
                      comments: vdm.post_prod_dpt.comments,
                  }
                  payload_item['status'] = vdm.post_prod_dpt.status
                  if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                    assignment = {
                        id: vdm.post_prod_dpt.post_prod_dpt_assignment.id,
                        status: vdm.post_prod_dpt.post_prod_dpt_assignment.status,
                        assignedName: vdm.post_prod_dpt.post_prod_dpt_assignment.assignedName,
                        comments: vdm.post_prod_dpt.post_prod_dpt_assignment.comments,
                        user_id: vdm.post_prod_dpt.post_prod_dpt_assignment.user_id,
                        video: vdm.post_prod_dpt.post_prod_dpt_assignment.video,
                        video_name: vdm.post_prod_dpt.post_prod_dpt_assignment.video_name,
                        premier_project: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project,
                        premier_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project_name,
                        after_project: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project,
                        after_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project_name,
                        illustrators: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators,
                        elements: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements,
                    }
                    responsable = vdm.post_prod_dpt.post_prod_dpt_assignment.assignedName
                    post_prod_dpt['assignment'] = assignment
                    if role == 'post-producer'
                      payload_item['status'] = vdm.post_prod_dpt.post_prod_dpt_assignment.status
                    end
                  end
                  payload_item['responsable'] = responsable
                  payload_item['postProdDept'] = post_prod_dpt
                end
              when 'productManager'
                production_status = 'no asignado'
                edition_status = 'no asignado'
                design_status = 'no asignado'
                post_prod_status = 'no asignado'
                if vdm.product_management != nil

                  payload_item['prodDept'] = vdm.production_dpt
                  if vdm.product_management.productionStatus != nil
                    production_status = vdm.product_management.productionStatus
                  end
                  if vdm.product_management.editionStatus != nil
                    edition_status = vdm.product_management.editionStatus
                  end
                  if vdm.product_management.designStatus != nil
                     design_status = vdm.product_management.designStatus
                  end
                  if vdm.product_management.postProductionStatus != nil
                    post_prod_status = vdm.product_management.postProductionStatus
                  end

                  payload_item['productManagement'] = vdm.product_management
                end
                payload_item['productionStatus'] = production_status
                payload_item['editionStatus'] = edition_status
                payload_item['designStatus'] = design_status
                payload_item['postProdStatus'] = post_prod_status
              when 'qa', 'qa-analyst'
                responsable = 'sin analista'
                payload_item['status'] = 'no asignado'
                if vdm.qa_dpt != nil
                  qa = {
                      id: vdm.qa_dpt.id,
                      status: vdm.qa_dpt.status,
                      comments: vdm.qa_dpt.comments,
                  }
                  payload_item['status'] = qa['status']
                  if vdm.qa_dpt.qa_assignment != nil
                    responsable = vdm.qa_dpt.qa_assignment.assignedName
                    qa['assignment'] = vdm.qa_dpt.qa_assignment
                    payload_item['status'] = vdm.qa_dpt.qa_assignment.status
                  end
                  payload_item['qa'] = qa
                  if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                    payload_item['video'] = vdm.post_prod_dpt.post_prod_dpt_assignment.video
                    payload_item['video_name'] = vdm.post_prod_dpt.post_prod_dpt_assignment.video_name
                  end
                end
                payload_item['qaResponsable'] = responsable
              else
                raise Exceptions::InvalidRoleException
            end
            if role != 'productManager'
              if vdm.production_dpt != nil
                payload_item['productionStatus'] = vdm.production_dpt.status
                if vdm.production_dpt.production_dpt_assignment != nil
                  payload_item['editionStatus'] = vdm.production_dpt.production_dpt_assignment.status
                end
              end
              if vdm.design_dpt != nil
                payload_item['designStatus'] = vdm.design_dpt.status
                if vdm.design_dpt.design_assignment != nil
                  payload_item['designStatus'] = vdm.design_dpt.design_assignment.status
                end
              end
              if vdm.post_prod_dpt != nil
                payload_item['postProdStatus'] = vdm.post_prod_dpt.status
                if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                  payload_item['postProdStatus'] = vdm.post_prod_dpt.post_prod_dpt_assignment.status
                end
              end
            end
            payload.push(payload_item)
          end
        end
      end

      users = User.all
      users.each do |user|
        if user.employee != nil
          employees.push({
             id: user.id,
             name: user.employee.firstName + ' ' + user.employee.firstSurname,
             username: user.username,
             roles: user.roles
           })
        end
      end
      render :json => { data: payload, subject: subject, employees: employees, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def getWholeVdm
    if params[:id] != nil
      vdm = Vdm.find(params[:id])
      production_dpt = nil;
      design_dpt = nil;
      post_prod_dpt = nil;
      if vdm.production_dpt != nil
        production_dpt = {
            id: vdm.production_dpt.id,
            status: vdm.production_dpt.production_dpt_assignment,
            comments: vdm.production_dpt.comments,
            script: vdm.production_dpt.script,
            script_name: vdm.production_dpt.script_name,
            screen_play: vdm.production_dpt.screen_play,
            screen_play_name: vdm.production_dpt.screen_play_name,
            master_planes: vdm.production_dpt.master_planes,
            detail_planes: vdm.production_dpt.detail_planes,
            wacom_vids: vdm.production_dpt.wacom_vids,
            prod_audios: vdm.production_dpt.prod_audios,
        }
        if vdm.production_dpt.production_dpt_assignment != nil
          production_dpt['assignment'] = {
              id: vdm.production_dpt.production_dpt_assignment.id,
              status: vdm.production_dpt.production_dpt_assignment.status,
              assignedName: vdm.production_dpt.production_dpt_assignment.assignedName,
              comments: vdm.production_dpt.production_dpt_assignment.comments,
              video_clip: vdm.production_dpt.production_dpt_assignment.video_clip,
              video_clip_name: vdm.production_dpt.production_dpt_assignment.video_clip_name,
              premier_project: vdm.production_dpt.production_dpt_assignment.premier_project,
              premier_project_name: vdm.production_dpt.production_dpt_assignment.premier_project_name
          }
        end
      end
      if vdm.design_dpt != nil
        design_dpt = {
            id: vdm.design_dpt.id,
            status: vdm.design_dpt.status,
            comments: vdm.design_dpt.comments,
        }
        if vdm.design_dpt.design_assignment != nil
          design_dpt['assignment'] = {
              id: vdm.design_dpt.design_assignment.id,
              status: vdm.design_dpt.design_assignment.status,
              assignedName: vdm.design_dpt.design_assignment.assignedName,
              comments: vdm.design_dpt.design_assignment.comments,
              illustrators: vdm.design_dpt.design_assignment.design_ilustrators,
              jpgs: vdm.design_dpt.design_assignment.design_jpgs,
              designed_presentation: vdm.design_dpt.design_assignment.designed_presentation,
              designed_presentation_name: vdm.design_dpt.design_assignment.designed_presentation_name,
              design_elements: vdm.design_dpt.design_assignment.design_elements
          }
        end
      end
      if vdm.post_prod_dpt != nil
        post_prod_dpt = {
            id: vdm.post_prod_dpt.id,
            status: vdm.post_prod_dpt.status,
            comments: vdm.post_prod_dpt.comments,
        }
        if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
          post_prod_dpt['assignment'] = {
              id: vdm.post_prod_dpt.post_prod_dpt_assignment.id,
              status: vdm.post_prod_dpt.post_prod_dpt_assignment.status,
              assignedName: vdm.post_prod_dpt.post_prod_dpt_assignment.assignedName,
              comments: vdm.post_prod_dpt.post_prod_dpt_assignment.comments,
              video: vdm.post_prod_dpt.post_prod_dpt_assignment.video,
              video_name: vdm.post_prod_dpt.post_prod_dpt_assignment.video_name,
              after_project: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project,
              after_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project_name,
              premier_project: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project,
              premier_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project_name,
              illustrators: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators,
              elements: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements
          }
        end
      end
      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          classDoc: vdm.classDoc,
          class_doc_name: vdm.class_doc_name,
          teacher_files: vdm.teacher_files,
          subject: vdm.classes_planification.subject_planification.subject,
          changes: vdm.vdm_changes,
          production_dpt: production_dpt,
          design_dpt: design_dpt,
          post_prod_dpt: post_prod_dpt


      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def updateVdm
    if request.raw_post != nil
      newVdm = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.find(newVdm['id'])
      prd_payload = nil
      design_payload = nil
      post_prod_payload = nil
      qa_payload = nil
      case newVdm['role']
        when 'contentLeader', 'contentAnalist'
          update_pre_prod_content(vdm, newVdm)
        when 'production', 'editor'
          prd_payload = update_production_content(vdm, newVdm)
        when 'designLeader', 'designer'
          design_payload = update_design_changes(vdm, newVdm)
        when 'postProLeader', 'post-producer'
          post_prod_payload = update_post_prod_content(vdm, newVdm)
        when 'qa', 'qa-analyst'
          if vdm.qa_dpt != nil
            if newVdm['qa'] != nil
              changes = []
              if newVdm['role'] == 'qa'
                if vdm.qa_dpt.comments != newVdm['qa']['comments']
                  change = VdmChange.new
                  change.changeDetail = 'Cambio de comentarios de qa'
                  if vdm.qa_dpt.comments != nil
                    change.changedFrom = vdm.qa_dpt.comments
                  else
                    change.changedFrom = 'vacio'
                  end
                  change.changedTo = newVdm['qa']['comments']
                  change.vdm_id = vdm.id
                  change.user_id = $currentPetitionUser['id']
                  change.uname = $currentPetitionUser['username']
                  change.videoId = vdm.videoId
                  change.changeDate = Time.now
                  change.department = 'qa'
                  vdm.qa_dpt.comments = newVdm['qa']['comments']
                  changes.push(change)
                end
                if newVdm['qa']['qaAsigned'] != nil
                  assignment = vdm.qa_dpt.qa_assignment
                  if assignment == nil
                    assignment = QaAssignment.new
                  end
                  assignment.qa_dpt_id = vdm.qa_dpt.id
                  assignment.user_id = newVdm['qaAsigned']['id']
                  assignment.assignedName = newVdm['qaAsigned']['name']
                  assignment.status = 'asignado'
                  assignment.save!
                  user = User.find(newVdm['qaAsigned']['id'])
                  UserNotifier.create_send_assigned_to_qa_analyst(vdm, user.employee).deliver
                  change = VdmChange.new
                  change.changeDetail = "Asignado video a Analista de qa " + newVdm['qaAsigned']['name']
                  change.vdm_id = vdm.id
                  change.user_id = $currentPetitionUser['id']
                  change.uname = $currentPetitionUser['username']
                  change.videoId = vdm.videoId
                  change.changeDate = Time.now
                  change.department = 'qa'
                  changes.push(change)
                end
                vdm.qa_dpt.save!
              end

              if newVdm['role'] == 'qa-analyst'
                if vdm.qa_dpt.qa_assignment != nil
                  if newVdm['qa']['assignment'] != nil
                    if vdm.qa_dpt.qa_assignment.comments != newVdm['qa']['assignment']['comments']
                      change = VdmChange.new
                      change.changeDetail = 'Cambio de comentarios de analista de qa'
                      if vdm.qa_dpt.comments != nil
                        change.changedFrom = vdm.qa_dpt.qa_assignment.comments
                      else
                        change.changedFrom = 'vacio'
                      end
                      change.changedTo = newVdm['qa']['assignment']['comments']
                      change.vdm_id = vdm.id
                      change.user_id = $currentPetitionUser['id']
                      change.uname = $currentPetitionUser['username']
                      change.videoId = vdm.videoId
                      change.changeDate = Time.now
                      change.department = 'qa'
                      vdm.qa_dpt.qa_assignment.comments = newVdm['qa']['assignment']['comments']
                      changes.push(change)
                    end
                    vdm.qa_dpt.qa_assignment.save!
                  end
                end

              end
            end
            qa_payload = {
                id: vdm.qa_dpt.id,
                status: vdm.qa_dpt.status,
                comments: vdm.qa_dpt.comments,
                assignment: vdm.qa_dpt.qa_assignment
            }
          end

        else
          raise Exceptions::InvalidRoleException
      end

      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          classDoc: vdm.classDoc,
          class_doc_name: vdm.class_doc_name,
          teacherFiles: vdm.teacher_files,
          subject: vdm.classes_planification.subject_planification.subject,
          prodDept: prd_payload,
          designDept: design_payload,
          postProdDept: post_prod_payload,
          qa: qa_payload
      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  rescue Exceptions::InvalidRoleException
    render :json => { status: 'UNAUTHORIZED', msg: 'No Autorizado'}, :status => :unauthorized
  end

  def update_pre_prod_content(vdm, new_vdm)
    changes = []
    if vdm.videoContent != new_vdm['videoContent']
      change = VdmChange.new
      change.changeDetail = 'Cambio de contenido'
      if vdm.videoContent != nil
        change.changedFrom = vdm.videoContent
      else
        change.changedFrom = 'vacio'
      end
      change.changedTo = new_vdm['videoContent']
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.department = 'pre-produccion'
      change.changeDate = Time.now
      changes.push(change)
    end
    if vdm.videoTittle != new_vdm['videoTittle']
      change = VdmChange.new
      change.changeDetail = 'Cambio de Titulo'
      if vdm.videoTittle != nil
        change.changedFrom = vdm.videoTittle
      else
        change.changedFrom = 'vacio'
      end

      change.changedTo = new_vdm['videoTittle']
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      changes.push(change)
    end

    if vdm.vdm_type != new_vdm['vdm_type']
      change = VdmChange.new
      change.changeDetail = 'Cambio de tipo'
      if vdm.vdm_type != nil
        change.changedFrom = vdm.vdm_type
      else
        change.changedFrom = 'vacio'
      end

      change.changedTo = new_vdm['type']
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      vdm.vdm_type = new_vdm['vdm_type']
      changes.push(change)
    end

    if vdm.status != new_vdm['status']
      change = VdmChange.new
      change.changeDetail = 'Cambio de estado'
      change.changedFrom = vdm.status
      change.changedTo = new_vdm['status']
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      changes.push(change)
      if new_vdm['status'] == 'procesado'
        case vdm.vdm_type
          when 'ejercicios', 'teorico', 'narrativo', 'experimental'
            production_dpt = vdm.production_dpt
            if production_dpt == nil
              production_dpt = ProductionDpt.new
            end
            production_dpt.status = 'asignado'
            production_dpt.vdm_id = new_vdm['id']
            production_dpt.save!
            vdm.classes_planification.subject_planification.save!

            UserNotifier.send_assigned_to_production(vdm).deliver
          when 'wacom'
            design_dpt = vdm.design_dpt
            if design_dpt == nil
              design_dpt = DesignDpt.new
            end
            design_dpt.status = 'asignado'
            design_dpt.vdm_id = new_vdm['id']
            design_dpt.save!
            assignment = design_dpt.design_assignment
            if  assignment == nil
              assignment = DesignAssignment.new
            end
            user = assign_task_to('designer')
            assignment.user_id = user.id
            assignment.status = 'asignado'
            assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
            assignment.design_dpt_id = design_dpt.id
            assignment.save!
            UserNotifier.send_assigned_to_designLeader(vdm).deliver
            UserNotifier.send_assigned_to_designer(vdm, user.employee).deliver
          else
        end
      end
    end
    if vdm.comments != new_vdm['comments']
      change = VdmChange.new
      change.changeDetail = 'Cambio de comentarios'
      if vdm.comments != nil
        change.changedFrom = vdm.comments
      else
        change.changedFrom = 'vacio'
      end
      change.changedTo = new_vdm['comments']
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      changes.push(change)
    end
    VdmChange.transaction do
      changes.each(&:save!)
    end

    vdm.videoContent = new_vdm['videoContent']
    vdm.videoTittle = new_vdm['videoTittle']
    vdm.status = new_vdm['status']
    vdm.comments = new_vdm['comments']
    vdm.save!
  end

  def update_production_content(vdm, newVdm)
    changes = []
    assignment = nil
    if vdm.production_dpt != nil
      if newVdm['prodDept'] != nil
        if newVdm['role'] == 'production'
          if vdm.production_dpt.comments != newVdm['prodDept']['comments']
            change = VdmChange.new
            change.changeDetail = 'Cambio de comentarios de produccion'
            if vdm.production_dpt.comments != nil
              change.changedFrom = vdm.production_dpt.comments
            else
              change.changedFrom = 'vacio'
            end
            change.changedTo = newVdm['prodDept']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
          end

          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'Grabacion completa'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.comments = 'Se grabo el video completo'
            change.changeDate = Time.now
            change.department = 'produccion'
            vdm.production_dpt.status = 'grabado'
            if vdm.production_dpt.production_dpt_assignment == nil || vdm.production_dpt.production_dpt_assignment.user_id == nil
              user = assign_task_to('editor')
              assignment = ProductionDptAssignment.new
              assignment.production_dpt_id = vdm.production_dpt.id
              assignment.status = 'asignado'
              assignment.user_id = user.id
              assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
              assignment.save!
              UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
            end
            if vdm.product_management != nil
              vdm.product_management.productionStatus = 'por aprobar'
              vdm.product_management.save!
            else
              management = ProductManagement.new
              management.productionStatus = 'por aprobar'
              management.vdm_id = vdm.id
              management.save!
            end
            changes.push(change)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro y conclucion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro y desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo conclusion y desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo desarrollo'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo intro'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = 'se grabo solo conclusion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            changes.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, changes)
          end
          if newVdm['prodDept']['assigned'] != nil || newVdm['assignedId'] != nil
            if newVdm['assignedId'] != nil
              user = User.find(newVdm['assignedId'])
            else
              user = User.find(newVdm['prodDept']['assigned']['id'])
            end
            if vdm.production_dpt.production_dpt_assignment == nil
              vdm.production_dpt.production_dpt_assignment = ProductionDptAssignment.new
            end
            vdm.production_dpt.production_dpt_assignment.user_id = user.id
            vdm.production_dpt.production_dpt_assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
            vdm.production_dpt.production_dpt_assignment.status = 'asignado'
            vdm.production_dpt.production_dpt_assignment.save!
            UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
          end
          vdm.production_dpt.intro = newVdm['intro']
          vdm.production_dpt.conclu = newVdm['conclu']
          vdm.production_dpt.vidDev = newVdm['vidDev']
          vdm.production_dpt.comments = newVdm['prodDept']['comments']
          vdm.production_dpt.save!
        end
      end

      if newVdm['prodDept']['assignment'] != nil
        if newVdm['role'] == 'editor'
          if vdm.production_dpt.production_dpt_assignment.comments != newVdm['prodDept']['assignment']['comments']
            change = VdmChange.new
            change.changeDetail = 'Cambio de comentarios de editor'
            if vdm.production_dpt.production_dpt_assignment.comments != nil
              change.changedFrom = vdm.production_dpt.production_dpt_assignment.comments
            else
              change.changedFrom = 'vacio'
            end
            change.changedTo = newVdm['prodDept']['assignment']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'edicion'
            changes.push(change)
          end
          if vdm.production_dpt.production_dpt_assignment.status != newVdm['prodDept']['assignment']['status']
            if newVdm['prodDept']['assignment']['status'] != 'no asignado'
              change = VdmChange.new
              change.changeDetail = 'Cambio de estado de editor'
              if vdm.production_dpt.production_dpt_assignment.status != nil
                change.changedFrom = vdm.production_dpt.production_dpt_assignment.status
              else
                change.changedFrom = 'vacio'
              end
              change.changedTo = newVdm['prodDept']['assignment']['status']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'edicion'
              changes.push(change)
            end
          end
          if newVdm['premierProject']
            change = VdmChange.new
            change.changeDetail = 'Cambio de proyecto premier de editor'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'edicion'
            vdm.production_dpt.production_dpt_assignment.premier_project_name = newVdm['premierProject']['filename']
            vdm.production_dpt.production_dpt_assignment.premier_project = newVdm['premierProject']['base64']
            change.changedTo = vdm.production_dpt.production_dpt_assignment.premier_project.url

            changes.push(change)
          end
          vdm.production_dpt.production_dpt_assignment.comments = newVdm['prodDept']['assignment']['comments']
          if newVdm['prodDept']['assignment']['status'] != 'no asignado'
            vdm.production_dpt.production_dpt_assignment.status = newVdm['prodDept']['assignment']['status']
          end
          vdm.production_dpt.production_dpt_assignment.save!
          if vdm.production_dpt.production_dpt_assignment.status == 'editado'
            UserNotifier.send_to_approved_to_production(vdm).deliver
          end
        end
      end
      VdmChange.transaction do
        changes.uniq.each(&:save!)
      end
    end
    if assignment == nil
      assignment = vdm.production_dpt.production_dpt_assignment
    end
    prd_payload = {
        status: vdm.production_dpt.status,
        script: vdm.production_dpt.script,
        screen_play: vdm.production_dpt.screen_play,
        script_name: vdm.production_dpt.script_name,
        screen_play_name: vdm.production_dpt.screen_play_name,
        comments: vdm.production_dpt.comments,
        intro: vdm.production_dpt.intro,
        conclu: vdm.production_dpt.conclu,
        vidDev: vdm.production_dpt.vidDev,
        assignment: assignment
    }
    return prd_payload
  end

  def update_design_changes(vdm, newVdm)
    changes = []
    assignment= {}
    if newVdm['dAsigned'] != nil
      if newVdm['role'] == 'designLeader'
        assignment = vdm.design_dpt.design_assignment
        if assignment == nil
          assignment = DesignAssignment.new
        end
        assignment.design_dpt_id = vdm.design_dpt.id
        assignment.user_id = newVdm['dAsigned']['id']
        assignment.assignedName = newVdm['dAsigned']['name']
        assignment.status = 'asignado'
        assignment.save!
        user = User.find(newVdm['dAsigned']['id'])
        UserNotifier.send_assigned_to_designer(vdm, user.employee).deliver
        change = VdmChange.new
        change.changeDetail = "Asignado video a diseñador " + newVdm['dAsigned']['name']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.department = 'diseño'
        changes.push(change)
      end
    end
    if newVdm['designDept'] != nil
      if newVdm['designDept']['assignment']
        if newVdm['role'] == 'designer'
          if vdm.design_dpt.design_assignment.comments != newVdm['designDept']['assignment']['comments']
            change = VdmChange.new
            change.changeDetail = "Cambio de comentarios de diseñador"
            if vdm.design_dpt.design_assignment.comments != nil
              change.changedFrom = vdm.design_dpt.design_assignment.comments
            else
              change.changedFrom = "vacio"
            end
            change.changedTo = newVdm['designDept']['assignment']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'diseño'
            changes.push(change)
            vdm.design_dpt.design_assignment.comments = newVdm['designDept']['assignment']['comments']
            vdm.design_dpt.design_assignment.save!
          end
          if vdm.design_dpt.design_assignment.status != newVdm['designDept']['assignment']['status']
            if newVdm['designDept']['assignment']['status'] != 'no asignado'
              change = VdmChange.new
              change.changeDetail = "Cambio de estado de diseñador"
              if vdm.design_dpt.design_assignment.status != nil
                change.changedFrom = vdm.design_dpt.design_assignment.status
              else
                change.changedFrom = "vacio"
              end
              change.changedTo = newVdm['designDept']['assignment']['status']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'diseño'
              changes.push(change)
              vdm.design_dpt.design_assignment.status = newVdm['designDept']['assignment']['status']
              vdm.design_dpt.design_assignment.save!
              if vdm.design_dpt.design_assignment.status == 'diseñado'
                UserNotifier.send_to_approved_to_designLeader(vdm).deliver
              end
            end
          end
          assignment = vdm.design_dpt.design_assignment
        end
      end
    end

    VdmChange.transaction do
      changes.uniq.each(&:save!)
    end
    design_payload = {
        status: vdm.design_dpt.status,
        comments: vdm.design_dpt.comments,
        assignment: assignment
    }
    return design_payload
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

  def checkForCompleteRecording(intro, vidDev, conclu, vdm, array)
    if intro == true && conclu == true && vidDev == true
      change = VdmChange.new
      change.changeDetail = 'Grabacion completa'
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.comments = 'Se grabo el video completo'
      change.changeDate = Time.now
      change.department = 'produccion'
      vdm.production_dpt.status = 'grabado'
      user = assign_task_to('editor')
      if vdm.production_dpt.production_dpt_assignment == nil || vdm.production_dpt.production_dpt_assignment.user_id == nil
        assignment = ProductionDptAssignment.new
        assignment.production_dpt_id = vdm.production_dpt.id
        assignment.status = 'asignado'
        assignment.user_id = user.id
        assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
        assignment.save!
        UserNotifier.send_assigned_to_editor(vdm, user.employee).deliver
      end
      if vdm.product_management != nil
        vdm.product_management.productionStatus = 'por aprobar'
        vdm.product_management.save!
      else
        management = ProductManagement.new
        management.productionStatus = 'por aprobar'
        management.vdm_id = vdm.id
        management.save!
      end
      array.push(change)
    end
  end

  def getDawereVdms

    sp = SubjectPlanification.find_by_subject_id(100)
    i = 0
    payload = []
    sp.classes_planifications.each do |cp|
      cp.vdms.reject{ |r| r.status == 'DESTROYED' }.each do |vdm|
        payload.push({
             id: vdm.id,
             videoId: vdm.videoId,
             videoTittle: vdm.videoTittle,
             videoContent: vdm.videoContent,
             status: vdm.status,
             comments: vdm.comments,
             cp: cp.as_json,
             prodDpt: vdm.production_dpt
         })
        i+=1
      end
    end
    render :json => { data: payload, subject: sp.subject, status: 'SUCCESS'}, :status => 200
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def addDawereVdm
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.new
      classPlan = ClassesPlanification.find(1000)
      subject = Subject.find(classPlan.subject_planification.subject_id)
      vdm.status = parameters['status']
      vdm.classes_planification_id = parameters['cp']['id']
      vdm.comments = parameters['comments']
      vdm.videoContent = parameters['videoContent']
      vdm.videoTittle = parameters['videoTittle']
      lastVid = Vdm.find_by_sql('Select MAX(number) from vdms v, classes_planifications cp, subject_planifications sp where sp.subject_id = ' + subject.id.to_s + ' and cp.subject_planification_id = sp.id and v.classes_planification_id = cp.id')
      if lastVid != nil
        vdmCount = lastVid.first.max + 1
      else
        vdmCount = 1
      end
      vdm.videoId = generateVideoId(subject, vdmCount)
      vdm.number = vdmCount
      vdm.save!
      change = VdmChange.new
      change.changeDetail = "Creacion"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      if parameters['justification'] != nil
        change.comments = parameters['justification']
      end
      change.changeDate = Time.now
      change.save!
      render :json => { data: vdm, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def checkFirstPeriodProcessed (vdmFP, nvdm, vm)
    processed = true
    if vm.classes_planification.subject_planification.firstPeriodCompleted == false
      vdmFP.each do |vdm|
        if vdm.status != 'procesado'
          if (vdm.id == nvdm['id'])
            if nvdm['status'] != 'procesado'
              processed = false
            end
          else
            processed = false
          end
        end
      end

    end
    return processed
  end

  def approveVdm
    if request.raw_post != nil
      params = ActiveSupport::JSON.decode(request.raw_post)
      vdm = Vdm.find(params['vdmId'])
      payload = {}
      case params['approval']
        when 'production'
          if vdm.production_dpt != nil
            change = VdmChange.new
            change.changeDetail = 'aprobado produccion por ' + params['approvedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'produccion'
            change.changedFrom = vdm.production_dpt.status
            change.changedTo = 'aprobado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            change.save!
            vdm.production_dpt.status = 'aprobado'
            vdm.production_dpt.save!
            if params['role'] == 'productManager'
              if vdm.product_management != nil
                vdm.product_management.productionStatus = 'aprobado'
                UserNotifier.send_approved_to_production(vdm).deliver
                vdm.product_management.save!
              end
            end
            payload = {
                prodDeptStatus: vdm.production_dpt.status,
                productManagement: vdm.product_management
            }
          end
        when 'edition'
          if vdm.production_dpt.production_dpt_assignment != nil
            change = VdmChange.new
            change.changeDetail = 'aprobado edicion por ' + params['approvedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'produccion'
            change.changedFrom = vdm.production_dpt.production_dpt_assignment.status
            change.changedTo = 'aprobado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            change.save!
            vdm.production_dpt.production_dpt_assignment.status = 'aprobado'
            vdm.production_dpt.production_dpt_assignment.save!
            if params['role'] == 'productManager'
              if vdm.production_dpt.status != 'aprobado'
                vdm.production_dpt.status = 'aprobado'
                vdm.production_dpt.save!
              end
              prod_mangement = vdm.product_management
              if prod_mangement == nil
                prod_mangement = ProductManagement.new
                prod_mangement.vdm_id = vdm.id
              end
              prod_mangement.productionStatus = 'aprobado'
              prod_mangement.editionStatus = 'aprobado'
              prod_mangement.save!
              UserNotifier.send_approved_to_editor(vdm, vdm.production_dpt.production_dpt_assignment.user.employee).deliver
              if vdm.vdm_type == 'wacom'
                postProd = vdm.post_prod_dpt
                if postProd == nil
                  postProd = PostProdDpt.new
                end
                postProd.status = 'asignado'
                postProd.vdm = vdm
                postProd.save!
                assignment = postProd.post_prod_dpt_assignment
                if  assignment == nil
                  assignment = PostProdDptAssignment.new
                end
                if assignment.user_id == nil
                  user = assign_task_to('post-producer')
                  assignment.user_id = user.id
                  assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
                  UserNotifier.send_assigned_to_post_producer(vdm, user.employee).deliver
                else
                  UserNotifier.send_assigned_to_post_producer(vdm, assignment.user.employee).deliver
                end
                assignment.status = 'asignado'
                assignment.post_prod_dpt_id = postProd.id
                assignment.save!
                UserNotifier.send_assigned_to_post_prod_leader(vdm).deliver
                prod_mangement.postProductionStatus = 'asignado'
              else
                design = vdm.design_dpt
                if design == nil
                  design = DesignDpt.new
                end
                design.status = 'asignado'
                design.vdm = vdm
                design.save!
                assignment = design.design_assignment
                if  assignment == nil
                  assignment = DesignAssignment.new
                end
                if assignment.user_id == nil
                  user = assign_task_to('designer')
                  assignment.user_id = user.id
                  assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
                  UserNotifier.send_assigned_to_designer(vdm, user.employee).deliver
                else
                  UserNotifier.send_assigned_to_designer(vdm, assignment.user.employee).deliver
                end
                assignment.status = 'asignado'
                assignment.design_dpt_id = design.id
                assignment.save!
                UserNotifier.send_assigned_to_designLeader(vdm).deliver
                prod_mangement.designStatus = 'asignado'
              end
              prod_mangement.save!
            else
              if vdm.product_management != nil
                vdm.product_management.editionStatus = 'por aprobar'
                vdm.product_management.save!
                UserNotifier.send_to_approved_to_product_Manager(vdm, 'Edicion').deliver
                upload_files_to_drive(vdm.id, 'production')
                upload_files_to_drive(vdm.id, 'edition')
              end
            end

            payload = {
                editionStatus: vdm.production_dpt.production_dpt_assignment.status,
                productManagement: vdm.product_management
            }
          end
        when 'design'
          designStatus = nil
          designAsignmentStatus = nil
          pmanagement = {}
          if vdm.design_dpt != nil
            if params['role'] == 'productManager'
              vdm.design_dpt.status = 'aprobado'
              UserNotifier.send_approved_to_designLeader(vdm).deliver
              vdm.design_dpt.save!
              designStatus = 'aprobado'
              management = vdm.product_management
              if management == nil
                management = ProductManagement.new
                management.designStatus = 'aprobado'
              end
              if vdm.vdm_type == 'wacom'
                production_dpt = vdm.production_dpt
                if production_dpt == nil
                  production_dpt = ProductionDpt.new
                end
                production_dpt.status = 'asignado'
                production_dpt.vdm_id = vdm.id
                production_dpt.save!
                UserNotifier.send_assigned_to_production(vdm).deliver
                management.designStatus = 'aprobado'
                management.productionStatus = 'asignado'
                management.save!
              else
                postProd = vdm.post_prod_dpt
                if postProd == nil
                  postProd = PostProdDpt.new
                end
                management.postProductionStatus = 'asignado'
                postProd.status = 'asignado'
                postProd.vdm = vdm
                postProd.save!
                assignment = postProd.post_prod_dpt_assignment
                if  assignment == nil
                  assignment = PostProdDptAssignment.new
                end
                if assignment.user_id == nil
                  user = assign_task_to('post-producer')
                  assignment.user_id = user.id
                  assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
                  UserNotifier.send_assigned_to_post_producer(vdm, user.employee).deliver
                else
                  UserNotifier.send_assigned_to_post_producer(vdm, assignment.user.employee).deliver
                end
                assignment.status = 'asignado'
                assignment.post_prod_dpt_id = postProd.id
                assignment.save!
                UserNotifier.send_assigned_to_post_prod_leader(vdm).deliver
                management.designStatus = 'aprobado'
                management.save!
              end
            else
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'aprobado'
                designAsignmentStatus = 'aprobado'
                vdm.design_dpt.design_assignment.save!
                UserNotifier.send_approved_to_designer(vdm, vdm.design_dpt.design_assignment.user.employee).deliver
                prod_managment = vdm.product_management
                if prod_managment == nil
                  prod_managment = ProductManagement.new
                  prod_managment.vdm_id = vdm.id
                end
                prod_managment.designStatus = 'por aprobar'
                prod_managment.save!
                UserNotifier.send_to_approved_to_product_Manager(vdm, 'Diseño').deliver
                upload_files_to_drive(vdm.id, 'design')
              end
            end
            change = VdmChange.new
            change.changeDetail = 'aprobado Diseño por ' + params['approvedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'diseño'
            change.changedFrom = vdm.design_dpt.status
            change.changedTo = 'aprobado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            change.save!
          end
          payload = {
              designStatus: designStatus,
              designAsignmentStatus: designAsignmentStatus,
              productManagement: vdm.product_management
          }
        when 'postProduction'
          postProdStatus = nil
          postProdAssignmentStatus = nil
          if vdm.post_prod_dpt != nil
            if params['role'] == 'productManager'
              vdm.post_prod_dpt.status = 'por aprobar qa'
              vdm.post_prod_dpt.save!
              UserNotifier.send_approved_to_post_prod_leader(vdm).deliver
              postProdStatus = 'por aprobar qa'
              if vdm.product_management != nil
                vdm.product_management.postProductionStatus = 'por aprobar qa'
                vdm.product_management.save!
              end
              qa = vdm.qa_dpt
              if vdm.qa_dpt == nil
                qa = QaDpt.new
              end
              qa.status = 'asignado'
              qa.vdm_id = vdm.id
              qa.save!
              assignment = qa.qa_assignment
              if  assignment == nil
                assignment = QaAssignment.new
              end
              if assignment.user_id == nil
                user = assign_task_to('qa-analyst')
                assignment.user_id = user.id
                assignment.assignedName = user.employee.firstName + ' ' + user.employee.firstSurname
                UserNotifier.send_assigned_to_qa_analyst(vdm, user.employee).deliver
              else
                UserNotifier.send_assigned_to_qa_analyst(vdm, assignment.user.employee).deliver
              end
              assignment.status = 'asignado'
              assignment.qa_dpt_id = qa.id
              assignment.save!
              UserNotifier.send_assigned_to_qaLeader(vdm).deliver

            else
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'aprobado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
                UserNotifier.send_approved_to_post_producer(vdm, vdm.post_prod_dpt.post_prod_dpt_assignment.user.employee).deliver
                postProdAssignmentStatus = 'aprobado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
                if vdm.product_management != nil
                  vdm.product_management.postProductionStatus = 'por aprobar'
                  vdm.product_management.save!
                  UserNotifier.send_to_approved_to_product_Manager(vdm, 'Post-produccion').deliver
                end
              end
            end
            change = VdmChange.new
            change.changeDetail = 'aprobado Post-Produccion por ' + params['approvedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'post-produccion'
            change.changedFrom = vdm.post_prod_dpt.status
            change.changedTo = 'aprobado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            change.save!
          end
          payload = {
              postProdStatus: postProdStatus,
              postProdAssignmentStatus: postProdAssignmentStatus,
              productManagement: vdm.product_management
          }
        when 'qa'
          if vdm.post_prod_dpt != nil && vdm.qa_dpt
            if params['role'] == 'qa' || params['role'] == 'qa-analyst'
              vdm.post_prod_dpt.status = 'aprobado'
              vdm.post_prod_dpt.save!
              vdm.qa_dpt.status = 'aprobado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment != nil
                vdm.qa_dpt.qa_assignment.status = 'aprobado'
                vdm.qa_dpt.qa_assignment.save!
              end
              UserNotifier.send_approved_to_post_prod_leader(vdm).deliver
              if vdm.product_management != nil
                vdm.product_management.postProductionStatus = 'aprobado'
                vdm.product_management.save!
              end
              upload_files_to_drive(vdm.id, 'post-production')
            end
            change = VdmChange.new
            change.changeDetail = 'aprobado Post-Produccion por ' + params['approvedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'post-produccion'
            change.changedFrom = vdm.post_prod_dpt.status
            change.changedTo = 'aprobado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            change.save!
            payload = {
                id: vdm.qa_dpt.id,
                status: vdm.qa_dpt.status,
                comments: vdm.qa_dpt.comments,
                assignment: vdm.qa_dpt.qa_assignment
            }
          end
      end
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def rejectVdm
    if request.raw_post != nil
      params = ActiveSupport::JSON.decode(request.raw_post)
      prdPayload = {}
      designPayload = {}
      postProdPayload = {}
      qa = {}
      vdm = Vdm.find(params['vdmId'])
      case params['rejection']
        when 'pre-production'
          parts = ''
          vdm.status = 'rechazado'
          if vdm.production_dpt != nil

            vdm.production_dpt.intro = false

            vdm.production_dpt.vidDev = false

            vdm.production_dpt.conclu = false
            if vdm.production_dpt.production_dpt_assignment != nil
              vdm.production_dpt.production_dpt_assignment.status = 'no asignado'
              vdm.production_dpt.production_dpt_assignment.save!
            end
            if vdm.design_dpt != nil
              vdm.design_dpt.status = 'no asignado'
              vdm.design_dpt.save!
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'no asignado'
                vdm.design_dpt.design_assignment.save!
              end
            end
            if vdm.post_prod_dpt != nil
              vdm.post_prod_dpt.status = 'no asignado'
              vdm.post_prod_dpt.save!
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'no asignado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
              end
            end
            if vdm.qa_dpt
              vdm.qa_dpt.status = 'no asignado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment
                vdm.qa_dpt.qa_assignment.status = 'no asignado'
                vdm.qa_dpt.qa_assignment.save!
              end
            end
            change = VdmChange.new
            change.changeDetail = 'rechazado por '+request['rejectedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'pre-produccion'
            change.changedFrom = vdm.production_dpt.status
            change.changedTo = 'rechazado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']

            if vdm.product_management != nil
              vdm.product_management.productionStatus = nil
              vdm.product_management.editionStatus = nil
              vdm.product_management.designStatus = nil
              vdm.product_management.postProductionStatus = nil
              vdm.product_management.save!
            end
            change.save!
            vdm.production_dpt.status = 'no asignado'
            vdm.production_dpt.save!
            UserNotifier.send_rejected_to_production(vdm).deliver
            if vdm.production_dpt != nil
              prdPayload = {
                  status: vdm.production_dpt.status,
                  comments: vdm.production_dpt.comments,
                  intro: vdm.production_dpt.intro,
                  conclu: vdm.production_dpt.conclu,
                  vidDev: vdm.production_dpt.vidDev,
                  assignment: vdm.production_dpt.production_dpt_assignment
              }
            end

            if vdm.design_dpt != nil
              designPayload = {
                  status: vdm.design_dpt.status,
                  comments: vdm.design_dpt.comments,
                  assignment: vdm.design_dpt.design_assignment
              }
            end

            if vdm.post_prod_dpt != nil
              postProdPayload = {
                  status: vdm.post_prod_dpt.status,
                  comments: vdm.post_prod_dpt.comments,
                  assignment: vdm.post_prod_dpt.post_prod_dpt_assignment
              }
            end
            if vdm.qa_dpt != nil
              qa = {
                  status: vdm.qa_dpt.status,
                  comments: vdm.qa_dpt.comments,
                  assignment: vdm.qa_dpt.qa_assignment
              }
            end
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                prodDept: prdPayload,
                productManagement: vdm.product_management,
                designDept: designPayload,
                postProdDept: postProdPayload,
                qa: qa
            }
            vdm.save!
          end
        when 'production'
          parts = ''
          if vdm.production_dpt != nil
            if params['intro'] == 'true'
              vdm.production_dpt.intro = false
              parts = parts + 'intro '
            end
            if params['vidDev'] == 'true'
              vdm.production_dpt.vidDev = false
              parts = parts + 'desarrollo '
            end
            if params['conclu'] == 'true'
              vdm.production_dpt.conclu = false
              parts = parts + 'conclusion '
            end
            if vdm.production_dpt.production_dpt_assignment != nil
              vdm.production_dpt.production_dpt_assignment.status = 'no asignado'
              vdm.production_dpt.production_dpt_assignment.save!
            end
            if vdm.design_dpt != nil
              vdm.design_dpt.status = 'no asignado'
              vdm.design_dpt.save!
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'no asignado'
                vdm.design_dpt.design_assignment.save!
              end
            end
            if vdm.post_prod_dpt != nil
              vdm.post_prod_dpt.status = 'no asignado'
              vdm.post_prod_dpt.save!
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'no asignado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
              end
            end
            if vdm.qa_dpt
              vdm.qa_dpt.status = 'no asignado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment
                vdm.qa_dpt.qa_assignment.status = 'no asignado'
                vdm.qa_dpt.qa_assignment.save!
              end
            end
            change = VdmChange.new
            change.changeDetail = 'rechazado por '+request['rejectedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'produccion'
            change.changedFrom = vdm.production_dpt.status
            change.changedTo = 'rechazado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            if params['justification'] != nil
              change.comments = params['justification']+ '. Partes a regrabar: ' + parts
            end
            if vdm.product_management != nil
              vdm.product_management.productionStatus = 'rechazado'
              vdm.product_management.editionStatus = nil
              vdm.product_management.designStatus = nil
              vdm.product_management.postProductionStatus = nil
              vdm.product_management.save!
            end
            change.save!
            vdm.production_dpt.status = 'rechazado'
            vdm.production_dpt.save!
            UserNotifier.send_rejected_to_production(vdm).deliver
            if vdm.production_dpt != nil
              prdPayload = {
                  status: vdm.production_dpt.status,
                  comments: vdm.production_dpt.comments,
                  intro: vdm.production_dpt.intro,
                  conclu: vdm.production_dpt.conclu,
                  vidDev: vdm.production_dpt.vidDev,
                  assignment: vdm.production_dpt.production_dpt_assignment
              }
            end

            if vdm.design_dpt != nil
              designPayload = {
                  status: vdm.design_dpt.status,
                  comments: vdm.design_dpt.comments,
                  assignment: vdm.design_dpt.design_assignment
              }
            end

            if vdm.post_prod_dpt != nil
              postProdPayload = {
                  status: vdm.post_prod_dpt.status,
                  comments: vdm.post_prod_dpt.comments,
                  assignment: vdm.post_prod_dpt.post_prod_dpt_assignment
              }
            end
            if vdm.qa_dpt != nil
              qa = {
                  status: vdm.qa_dpt.status,
                  comments: vdm.qa_dpt.comments,
                  assignment: vdm.qa_dpt.qa_assignment
              }
            end
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                prodDept: prdPayload,
                productManagement: vdm.product_management,
                designDept: designPayload,
                postProdDept: postProdPayload,
                qa: qa
            }
          end
        when 'edition'
          if vdm.production_dpt.production_dpt_assignment != nil
            if vdm.design_dpt != nil
              vdm.design_dpt.status = 'no asignado'
              vdm.design_dpt.save!
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'no asignado'
                vdm.design_dpt.design_assignment.save!
              end
            end
            if vdm.post_prod_dpt != nil
              vdm.post_prod_dpt.status = 'no asignado'
              vdm.post_prod_dpt.save!
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'no asignado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
              end
            end
            if vdm.qa_dpt
              vdm.qa_dpt.status = 'no asignado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment
                vdm.qa_dpt.qa_assignment.status = 'no asignado'
                vdm.qa_dpt.qa_assignment.save!
              end
            end
            change = VdmChange.new
            change.changeDetail = 'rechazado por '+request['rejectedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'edicion'
            change.changedFrom = vdm.production_dpt.status
            change.changedTo = 'rechazado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            if params['justification'] != nil
              change.comments = params['justification']
            end
            change.save!
            vdm.production_dpt.production_dpt_assignment.status = 'rechazado'
            vdm.production_dpt.production_dpt_assignment.save!
            user = vdm.production_dpt.production_dpt_assignment.user.employee
            UserNotifier.send_rejected_to_editor(vdm, user).deliver
            if vdm.product_management != nil
              vdm.product_management.editionStatus = 'rechazado'
              vdm.product_management.designStatus = nil
              vdm.product_management.postProductionStatus = nil
              vdm.product_management.save!
            end
            if vdm.production_dpt != nil
              prdPayload = {
                  status: vdm.production_dpt.status,
                  comments: vdm.production_dpt.comments,
                  intro: vdm.production_dpt.intro,
                  conclu: vdm.production_dpt.conclu,
                  vidDev: vdm.production_dpt.vidDev,
                  assignment: vdm.production_dpt.production_dpt_assignment
              }
            end

            if vdm.design_dpt != nil
              designPayload = {
                  status: vdm.design_dpt.status,
                  comments: vdm.design_dpt.comments,
                  assignment: vdm.design_dpt.design_assignment
              }
            end

            if vdm.post_prod_dpt != nil
              postProdPayload = {
                  status: vdm.post_prod_dpt.status,
                  comments: vdm.post_prod_dpt.comments,
                  assignment: vdm.post_prod_dpt.post_prod_dpt_assignment
              }
            end
            if vdm.qa_dpt != nil
              qa = {
                  status: vdm.qa_dpt.status,
                  comments: vdm.qa_dpt.comments,
                  assignment: vdm.qa_dpt.qa_assignment
              }
            end
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                prodDept: prdPayload,
                productManagement: vdm.product_management,
                designDept: designPayload,
                postProdDept: postProdPayload,
                qa: qa
            }
          end
        when 'design'
          if vdm.design_dpt != nil
            if params['role'] == 'productManager'
              vdm.design_dpt.status = 'rechazado'
              vdm.design_dpt.save!
              UserNotifier.send_rejected_to_designLeader(vdm).deliver
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'rechazado'
                vdm.design_dpt.design_assignment.save!
                UserNotifier.send_rejected_to_designer(vdm, vdm.design_dpt.design_assignment.user.employee).deliver
              end
            else
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'rechazado'
                vdm.design_dpt.design_assignment.save!
                UserNotifier.send_rejected_to_designer(vdm, vdm.design_dpt.design_assignment.user.employee).deliver
              end
            end
            if vdm.post_prod_dpt != nil
              vdm.post_prod_dpt.status = 'no asignado'
              vdm.post_prod_dpt.save!
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'no asignado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
              end
            end
            if vdm.qa_dpt
              vdm.qa_dpt.status = 'no asignado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment
                vdm.qa_dpt.qa_assignment.status = 'no asignado'
                vdm.qa_dpt.qa_assignment.save!
              end
            end
            change = VdmChange.new
            change.changeDetail = 'rechazado por '+request['rejectedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'diseño'
            change.changedFrom = vdm.design_dpt.status
            change.changedTo = 'rechazado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            if params['justification'] != nil
              change.comments = params['justification']
            end
            change.save!
            if vdm.product_management != nil
              vdm.product_management.designStatus = 'rechazado'
              vdm.product_management.postProductionStatus = nil
              vdm.product_management.save!
            end
            if vdm.design_dpt != nil
              designPayload = {
                  status: vdm.design_dpt.status,
                  comments: vdm.design_dpt.comments,
                  assignment: vdm.design_dpt.design_assignment
              }
            end
            if vdm.post_prod_dpt != nil
              postProdPayload = {
                  status: vdm.post_prod_dpt.status,
                  comments: vdm.post_prod_dpt.comments,
                  assignment: vdm.post_prod_dpt.post_prod_dpt_assignment
              }
            end
            if vdm.qa_dpt != nil
              qa = {
                  status: vdm.qa_dpt.status,
                  comments: vdm.qa_dpt.comments,
                  assignment: vdm.qa_dpt.qa_assignment
              }
            end
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                designDept: designPayload,
                postProdDept: postProdPayload,
                productManagement: vdm.product_management,
                qa: qa
            }
          end
        when 'postProduction'
          if vdm.design_dpt != nil
            if params['role'] == 'productManager'
              vdm.post_prod_dpt.status = 'rechazado'
              vdm.post_prod_dpt.save!
              UserNotifier.send_rejected_to_post_prod_leader(vdm).deliver
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'rechazado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
                UserNotifier.send_rejected_to_post_producer(vdm, vdm.post_prod_dpt.post_prod_dpt_assignment.user.employee).deliver
              end
            else
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'rechazado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
                UserNotifier.send_rejected_to_post_producer(vdm, vdm.post_prod_dpt.post_prod_dpt_assignment.user.employee).deliver
              end
            end
            if vdm.qa_dpt
              vdm.qa_dpt.status = 'no asignado'
              vdm.qa_dpt.save!
              if vdm.qa_dpt.qa_assignment
                vdm.qa_dpt.qa_assignment.status = 'no asignado'
                vdm.qa_dpt.qa_assignment.save!
              end
            end
            change = VdmChange.new
            change.changeDetail = 'rechazado por '+request['rejectedFrom']
            change.changeDate = Time.now
            change.user_id = $currentPetitionUser['id']
            change.vdm_id = vdm.id
            change.department = 'post-produccion'
            change.changedFrom = vdm.design_dpt.status
            change.changedTo = 'rechazado'
            change.videoId = vdm.videoId
            change.uname = $currentPetitionUser['username']
            if params['justification'] != nil
              change.comments = params['justification']
            end
            change.save!
            if vdm.product_management != nil
              vdm.product_management.postProductionStatus = 'rechazado'
              vdm.product_management.save!
            end

            if vdm.post_prod_dpt != nil
              postProdPayload = {
                  status: vdm.post_prod_dpt.status,
                  comments: vdm.post_prod_dpt.comments,
                  assignment: vdm.post_prod_dpt.post_prod_dpt_assignment
              }
            end
            if vdm.qa_dpt != nil
              qa = {
                  status: vdm.qa_dpt.status,
                  comments: vdm.qa_dpt.comments,
                  assignment: vdm.qa_dpt.qa_assignment
              }
            end

            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                postProdDept: postProdPayload,
                designDept: vdm.design_dpt,
                prodDept: vdm.production_dpt,
                productManagement: vdm.product_management,
                qa: qa
            }
          end
      end
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def upload_edition_files
    msg = 'Archivo guardado exitosamente'
    response = nil
    if request != nil && params[:id] != nil
      vdm = Vdm.find(params[:id])
      if vdm.production_dpt.production_dpt_assignment != nil
        if params[:file] != nil
          case params[:file_type]
            when 'video_clip'
              vdm.production_dpt.production_dpt_assignment.video_clip_name = params[:file].original_filename
              vdm.production_dpt.production_dpt_assignment.video_clip = params[:file]
              vdm.production_dpt.production_dpt_assignment.save!
              response = {
                  video_clip: vdm.production_dpt.production_dpt_assignment.video_clip,
                  video_clip_name: vdm.production_dpt.production_dpt_assignment.video_clip_name
              }
            when 'premier'
              vdm.production_dpt.production_dpt_assignment.premier_project_name = params[:file].original_filename
              vdm.production_dpt.production_dpt_assignment.premier_project = params[:file]
              vdm.production_dpt.production_dpt_assignment.save!
              response = {
                  premier_project: vdm.production_dpt.production_dpt_assignment.premier_project,
                  premier_project_name: vdm.production_dpt.production_dpt_assignment.premier_project_name
              }
            else
              msg = 'tipo de archivo no admitido'
          end
        end
      end
    end
    render :json => { data: response, status: 'SUCCESS', msg: msg}, :status => 200
  end

  def upload_pre_production_files
    msg = 'Archivo guardado exitosamente'
    response = nil
    changes = []
    if request != nil && params[:id] != nil
      vdm = Vdm.find(params[:id])
      case params[:doc]
        when 'class_doc'
          if params[:upload] != nil
            change = VdmChange.new
            change.changeDetail = 'Cambio de documento'
            change.vdm_id = vdm.id
            if vdm.classDoc != nil
              change.changedFrom = vdm.classDoc.url
            else
              change.changedFrom = 'vacio'
            end
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'pre-produccion'
            vdm.classDoc = params[:upload] #create a document associated with the item that has just been created end
            vdm.class_doc_name = params[:upload].original_filename
            change.changedTo = vdm.classDoc.url
            changes.push(change)
            if vdm.classDoc.path != nil
              FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/CONTENIDO/PRESENTACION ORIGINAL/'
              FileUtils.cp(vdm.classDoc.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/CONTENIDO/PRESENTACION ORIGINAL/'+vdm.class_doc_name)
            end
            response = {
                class_doc: vdm.classDoc,
                class_doc_name: vdm.class_doc_name
            }
          end
        when 'teacher_files'
          teacher_files = []
          params[:upload].each do |tf|
            uploaded_file = tf[1]
            change = VdmChange.new
            change.changeDetail = 'Agregado nuevo material de profesor'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'pre-produccion'
            changes.push(change)
            file = TeacherFile.new
            file.file = uploaded_file
            file.vdm_id = vdm.id
            file.file_name = uploaded_file.original_filename
            teacher_files.push(file)
            FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/CONTENIDO/ENTREGADO PROFE/'
            FileUtils.cp(file.file.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/CONTENIDO/ENTREGADO PROFE/'+file.file_name)
          end
          if teacher_files.count >= 1
            TeacherFile.transaction do
              teacher_files.each(&:save!)
            end
          end
          response = {
              teacher_files: vdm.teacher_files
          }
        else
          msg = 'tipo de archivo no admitido'
      end
      vdm.save!
      VdmChange.transaction do
        changes.each(&:save!)
      end
    end
    render :json => { data: response, status: 'SUCCESS', msg: msg}, :status => 200
  end

  def upload_production_files
    msg = 'Archivos guardados exitosamente'
    response = nil
    changes = []
    if request != nil && params[:id] != nil
      vdm = Vdm.find(params[:id])
      if vdm.production_dpt != nil
        case params[:doc]
          when 'script'
            change = VdmChange.new
            change.changeDetail = 'Cambio de libreto de produccion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            vdm.production_dpt.script_name = params[:upload].original_filename

            vdm.production_dpt.script = params[:upload]
            change.changedTo = vdm.production_dpt.script.url
            change.department = 'produccion'
            changes.push(change)
            response = {
                script: vdm.production_dpt.script,
                script_name: vdm.production_dpt.script_name
            }
          when 'screen_play'
            change = VdmChange.new
            change.changeDetail = 'Cambio de Guion de produccion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            vdm.production_dpt.screen_play_name = params[:upload].original_filename

            vdm.production_dpt.screen_play = params[:upload]
            change.changedTo = vdm.production_dpt.screen_play.url

            change.department = 'produccion'
            changes.push(change)
            response = {
                screen_play: vdm.production_dpt.screen_play,
                screen_play_name: vdm.production_dpt.screen_play_name
            }
          else
            msg = 'tipo de archivo no admitido'
        end

        vdm.production_dpt.save!
        VdmChange.transaction do
          changes.each(&:save!)
        end
      end
    end
    render :json => { data: response, status: 'SUCCESS', msg: msg}, :status => 200
  end

  def upload_design_files
    msg = 'Archivos guardados exitosamente'
    response = nil
    changes = []
    if request != nil && params[:id] != nil
      vdm = Vdm.find(params[:id])
      if vdm.design_dpt.design_assignment != nil
        case params[:type]
          when 'ilustrators'
            ilustrators = []
            params[:upload].each do |il|
              uploaded_file = il[1]
              change = VdmChange.new
              change.changeDetail = 'Agregado nuevo ilustrator por diseño'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'diseño'
              changes.push(change)
              file = DesignIlustrator.new
              file.file = uploaded_file
              file.design_assignment_id = vdm.design_dpt.design_assignment.id
              file.file_name = uploaded_file.original_filename
              ilustrators.push(file)
            end
            if ilustrators.count >= 1
              TeacherFile.transaction do
                ilustrators.each(&:save!)
              end
            end
            response = {
                design_ilustrators: vdm.design_dpt.design_assignment.design_ilustrators
            }
          when 'jpgs'
            images = []
            params[:upload].each do |im|
              uploaded_file = im[1]
              change = VdmChange.new
              change.changeDetail = 'Agregada nueva imagen'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'diseño'
              changes.push(change)
              file = DesignJpg.new
              file.file = uploaded_file
              file.design_assignment_id = vdm.design_dpt.design_assignment.id
              file.file_name = uploaded_file.original_filename
              images.push(file)
            end
            if images.count >= 1
              TeacherFile.transaction do
                images.each(&:save!)
              end
            end
            response = {
                design_jpgs: vdm.design_dpt.design_assignment.design_jpgs
            }
          when 'designed_presentation'
            change = VdmChange.new
            change.changeDetail = 'Cambio de presentacion'
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            vdm.design_dpt.design_assignment.designed_presentation_name = params[:upload].original_filename

            vdm.design_dpt.design_assignment.designed_presentation = params[:upload]
            change.changedTo = vdm.design_dpt.design_assignment.designed_presentation.url
            change.department = 'diseño'
            changes.push(change)
            vdm.design_dpt.design_assignment.save!
            response = {
                designed_presentation: vdm.design_dpt.design_assignment.designed_presentation,
                designed_presentation_name: vdm.design_dpt.design_assignment.designed_presentation_name
            }
          when 'elements'
            elements = []
            params[:upload].each do |el|
              uploaded_file = el[1]
              change = VdmChange.new
              change.changeDetail = 'Agregado nuevo elemento'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'diseño'
              changes.push(change)
              file = DesignElement.new
              file.file = uploaded_file
              file.design_assignment_id = vdm.design_dpt.design_assignment.id
              file.file_name = uploaded_file.original_filename
              elements.push(file)
            end
            if elements.count >= 1
              TeacherFile.transaction do
                elements.each(&:save!)
              end
            end
            response = {
                elements: vdm.design_dpt.design_assignment.design_elements
            }
          else
            msg = 'tipo de archivo no admitido'
        end

        vdm.save!
        VdmChange.transaction do
          changes.each(&:save!)
        end
      end
    end
    render :json => { data: response, status: 'SUCCESS', msg: msg}, :status => 200
  end

  def upload_post_production_files
    msg = 'Archivo(s) guardado(s) exitosamente'
    response = nil
    changes = []
    if request != nil && params[:id] != nil
      vdm = Vdm.find(params[:id])
      if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
        case params[:file_type]
          when 'final_vid'
            if params[:upload] != nil
              change = VdmChange.new
              change.changeDetail = 'Cambio de video'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              vdm.post_prod_dpt.post_prod_dpt_assignment.video = params[:upload] #create a document associated with the item that has just been created end
              vdm.post_prod_dpt.post_prod_dpt_assignment.video_name = params[:upload].original_filename
              change.changedTo = vdm.post_prod_dpt.post_prod_dpt_assignment.video.url
              changes.push(change)
              response = {
                  video: vdm.post_prod_dpt.post_prod_dpt_assignment.video,
                  video_name: vdm.post_prod_dpt.post_prod_dpt_assignment.video_name
              }
            end
          when 'premier_project'
            if params[:upload] != nil
              change = VdmChange.new
              change.changeDetail = 'Cambio de proyecto premier'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project = params[:upload] #create a document associated with the item that has just been created end
              vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project_name = params[:upload].original_filename
              change.changedTo = vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project.url
              changes.push(change)
              response = {
                  premier_project: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project,
                  premier_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project_name
              }
            end
          when 'after_project'
            if params[:upload] != nil
              change = VdmChange.new
              change.changeDetail = 'Cambio de proyecto after'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              vdm.post_prod_dpt.post_prod_dpt_assignment.after_project = params[:upload] #create a document associated with the item that has just been created end
              vdm.post_prod_dpt.post_prod_dpt_assignment.after_project_name = params[:upload].original_filename
              change.changedTo = vdm.post_prod_dpt.post_prod_dpt_assignment.after_project.url
              changes.push(change)
              response = {
                  after_project: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project,
                  after_project_name: vdm.post_prod_dpt.post_prod_dpt_assignment.after_project_name
              }
            end
          when 'illustrators'
            illustrators = []
            params[:upload].each do |il|
              uploaded_file = il[1]
              change = VdmChange.new
              change.changeDetail = 'Agregado nuevo illustrator'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              changes.push(change)
              file = PostProdIllustrator.new
              file.file = uploaded_file
              file.post_prod_dpt_assignment_id = vdm.post_prod_dpt.post_prod_dpt_assignment.id
              file.file_name = uploaded_file.original_filename
              illustrators.push(file)
            end
            if illustrators.count >= 1
              TeacherFile.transaction do
                illustrators.each(&:save!)
              end
            end
            response = {
                illustrators: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators
            }
          when 'elements'
            elements = []
            params[:upload].each do |el|
              uploaded_file = el[1]
              change = VdmChange.new
              change.changeDetail = 'Agregado nuevo elemento'
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'post-produccion'
              changes.push(change)
              file = PostProdElement.new
              file.file = uploaded_file
              file.post_prod_dpt_assignment_id = vdm.post_prod_dpt.post_prod_dpt_assignment.id
              file.file_name = uploaded_file.original_filename
              elements.push(file)
            end
            if elements.count >= 1
              TeacherFile.transaction do
                elements.each(&:save!)
              end
            end
            response = {
                elements: vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements
            }
          else
            msg = 'tipo de archivo no admitido'
        end
        vdm.post_prod_dpt.post_prod_dpt_assignment.save!
        VdmChange.transaction do
          changes.each(&:save!)
        end
      end

    end
    render :json => { data: response, status: 'SUCCESS', msg: msg}, :status => 200
  end

  def assign_task_to(department)
    assignments = nil
    employee = nil
    users = User.joins(:roles).where(:roles => {role: department, status: 'enabled'})
    users.each do |u|
      case department
        when 'editor'
          if assignments == nil
            assignments = u.production_dpt_assignments.where(:status => 'asignado').count
          else
            if u.production_dpt_assignments.where(:status => 'asignado').count <= assignments || u.production_dpt_assignments == nil
              employee = u
            end
          end
        when 'designer'
          if assignments == nil
            assignments = u.design_assignments.where(:status => 'asignado').count
          else
            if u.design_assignments.where(:status => 'asignado').count <= assignments || u.design_assignments == nil
              employee = u
            end
          end
        when 'post-producer'
          if assignments == nil
            assignments = u.post_prod_dpt_assignments.where(:status => 'asignado').count
          else
            if u.post_prod_dpt_assignments.where(:status => 'asignado').count <= assignments || u.post_prod_dpt_assignments == nil
              employee = u
            end
          end
        when 'qa-analyst'
          if assignments == nil
            assignments = u.qa_assignments.where(:status => 'asignado').count
          else
            if u.qa_assignments.where(:status => 'asignado').count <= assignments || u.qa_assignments == nil
              employee = u
            end
          end
      end
      if employee == nil
        employee = u
      end
    end
    return employee
  end

  def upload_files_to_drive(id, department)
    if id != nil && department != nil
      vdm = Vdm.find(id)
      if vdm != nil
        case department
          when 'production'
            if vdm.production_dpt != nil
              if vdm.production_dpt.script != nil && vdm.production_dpt.script.path != nil
                FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/SCRIPT/'
                FileUtils.cp(vdm.production_dpt.script.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/SCRIPT/'+vdm.production_dpt.script_name)
              end
              if vdm.production_dpt.screen_play != nil && vdm.production_dpt.screen_play.path != nil
                FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/GUION/'
                FileUtils.cp(vdm.production_dpt.screen_play.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/GUION/'+vdm.production_dpt.screen_play_name)
              end
            end
          when 'edition'
            if vdm.production_dpt != nil
              if vdm.production_dpt.production_dpt_assignment != nil
                if vdm.production_dpt.production_dpt_assignment.video_clip != nil && vdm.production_dpt.production_dpt_assignment.video_clip.path != nil
                  FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/EDICION/'
                  FileUtils.cp(vdm.production_dpt.production_dpt_assignment.video_clip.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/EDICION/'+ vdm.production_dpt.production_dpt_assignment.video_clip_name)
                end
                if vdm.production_dpt.production_dpt_assignment.premier_project != nil && vdm.production_dpt.production_dpt_assignment.premier_project.path != nil
                  FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/EDICION/'
                  FileUtils.cp(vdm.production_dpt.production_dpt_assignment.premier_project.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/PRODUCCION/EDICION/' + vdm.production_dpt.production_dpt_assignment.premier_project_name)
                end
              end
            end
          when 'design'
            if vdm.design_dpt != nil && vdm.design_dpt.design_assignment != nil
              if vdm.design_dpt.design_assignment != nil
                if vdm.design_dpt.design_assignment.design_jpgs.count >= 1
                  vdm.design_dpt.design_assignment.design_jpgs.each do |file|
                    FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/JPGS/'
                    FileUtils.cp(file.file.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/JPGS/'+file.file_name)
                  end
                end
                if vdm.design_dpt.design_assignment.design_ilustrators.count >= 1
                  vdm.design_dpt.design_assignment.design_ilustrators.each do |file|
                    FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/ILLUSTRATORS/'
                    FileUtils.cp(file.file.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/ILLUSTRATORS/'+file.file_name)
                  end
                end
                if vdm.design_dpt.design_assignment.design_elements.count >= 1
                  vdm.design_dpt.design_assignment.design_elements.each do |file|
                    FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/ELEMENTOS/'
                    FileUtils.cp(file.file.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/ELEMENTOS/'+file.file_name)
                  end
                end
                if vdm.design_dpt.design_assignment.designed_presentation != nil && vdm.design_dpt.design_assignment.designed_presentation.path != nil
                  FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/PRESENTACION/'
                  FileUtils.cp(vdm.design_dpt.design_assignment.designed_presentation.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/DISENO GRAFICO/PRESENTACION/'+vdm.design_dpt.design_assignment.designed_presentation_name)
                end
              end
            end
          when 'post-production'
            if vdm.post_prod_dpt != nil && vdm.post_prod_dpt.post_prod_dpt_assignment != nil
              route = $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/'+vdm.videoId+'/POSTPRODUCCION/'
              FileUtils::mkdir_p route
              if vdm.post_prod_dpt.post_prod_dpt_assignment.video != nil && vdm.post_prod_dpt.post_prod_dpt_assignment.video.path != nil
                FileUtils::mkdir_p  route + 'VIDEO FINAL/'
                FileUtils.cp(vdm.post_prod_dpt.post_prod_dpt_assignment.video.path, route + 'VIDEO FINAL/'+vdm.post_prod_dpt.post_prod_dpt_assignment.video_name)
                FileUtils::mkdir_p $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/PUBLICACIONES/'
                FileUtils.cp(vdm.post_prod_dpt.post_prod_dpt_assignment.video.path, $drive_copy_route+vdm.classes_planification.subject_planification.subject.grade.name+'/'+vdm.classes_planification.subject_planification.subject.name+'/PUBLICACIONES/'+vdm.post_prod_dpt.post_prod_dpt_assignment.video_name)

              end
              if vdm.post_prod_dpt.post_prod_dpt_assignment.after_project != nil && vdm.post_prod_dpt.post_prod_dpt_assignment.after_project.path != nil
                FileUtils::mkdir_p  route + 'AFTER/'
                FileUtils.cp(vdm.post_prod_dpt.post_prod_dpt_assignment.after_project.path, route + 'AFTER/'+vdm.post_prod_dpt.post_prod_dpt_assignment.after_project_name)
              end
              if vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project != nil && vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project.path != nil
                FileUtils::mkdir_p  route + 'PREMIER/'
                FileUtils.cp(vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project.path, route + 'PREMIER/'+vdm.post_prod_dpt.post_prod_dpt_assignment.premier_project_name)
              end
              if vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators != nil && vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators.count >= 1
                FileUtils::mkdir_p  route + 'ILLUSTRATORS/'
                vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_illustrators.each do |file|
                  FileUtils.cp(file.file.path, route + 'ILLUSTRATORS/'+file.file_name)
                end
              end
              if vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements != nil && vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements.count >= 1
                FileUtils::mkdir_p  route + 'ELEMENTOS/'
                vdm.post_prod_dpt.post_prod_dpt_assignment.post_prod_elements.each do |file|
                  FileUtils.cp(file.file.path,  route + 'ELEMENTOS/'+file.file_name)
                end
              end
            end
        end
      end
    end
  end

  def resume_file
    if params[:file_name] != nil

      path = "#{$big_files_tmp_route}/#{params[:file_name]}"
      FileUtils::mkdir_p path
      size = Dir[File.join(path, '**', '*')].count { |file| File.file?(file) }

      render :json => { size: size, status: 'SUCCESS'}, :status => 200
    else
      render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
    end
  end

  def raw_material_upload
    size = 0
    payload = nil
    FileUtils::mkdir_p "#{$big_files_tmp_route}/#{params[:upload].original_filename}"
    dir = "#{$big_files_tmp_route}/#{params[:upload].original_filename}"
    chunk = "#{dir}/#{params[:upload].original_filename}.part#{params[:_chunkNumber]}"

    # Move the uploaded chunk to the directory
    FileUtils.mv params[:upload].tempfile, chunk

    filesize = params[:_totalSize].to_i
    current_size = params[:_chunkNumber].to_i * params[:_chunkSize].to_i

    if (current_size + params[:_currentChunkSize].to_i) >= filesize
      vdm = Vdm.find(params[:vdm_id])
      absolute_route = "#{$files_root}/#{vdm.classes_planification.subject_planification.subject.grade.name}/#{vdm.classes_planification.subject_planification.subject.name}/#{vdm.videoId}/raw_material/#{params[:file_type]}/"
      relative_route = "/#{vdm.classes_planification.subject_planification.subject.grade.name}/#{vdm.classes_planification.subject_planification.subject.name}/#{vdm.videoId}/raw_material/#{params[:file_type]}"
      FileUtils::mkdir_p absolute_route

      if vdm != nil && vdm.production_dpt != nil
        #Create a target file
        File.open("#{absolute_route}/#{params[:upload].original_filename}","a") do |target|
          #Loop trough the chunks
          for i in 0..params[:_chunkNumber].to_i
            #Select the chunk
            chunk = File.open("#{dir}/#{params[:upload].original_filename}.part#{i}", 'r').read

            #Write chunk into target file
            chunk.each_line do |line|
              target << line
            end

            #Deleting chunk
            FileUtils.rm "#{dir}/#{params[:upload].original_filename}.part#{i}", :force => true
          end
        end
        case params[:file_type]
          when 'master_planes'
            rec = MasterPlane.new
            rec.production_dpt_id = vdm.production_dpt.id
            rec.file_name = params[:upload].original_filename
            rec.file = "#{relative_route}/#{params[:upload].original_filename}"
            rec.save!
            payload = {
                files: vdm.production_dpt.master_planes
            }
          when 'detail_planes'
            rec = DetailPlane.new
            rec.production_dpt_id = vdm.production_dpt.id
            rec.file_name = params[:upload].original_filename
            rec.file = "#{relative_route}/#{params[:upload].original_filename}"
            rec.save!
            payload = {
                files: vdm.production_dpt.detail_planes
            }
          when 'wacom_vids'
            rec = WacomVid.new
            rec.production_dpt_id = vdm.production_dpt.id
            rec.file_name = params[:upload].original_filename
            rec.file = "#{relative_route}/#{params[:upload].original_filename}"
            rec.save!
            payload = {
                files: vdm.production_dpt.wacom_vids
            }
          when 'prod_audios'
            rec = ProdAudio.new
            rec.production_dpt_id = vdm.production_dpt.id
            rec.file_name = params[:upload].original_filename
            rec.file = "#{relative_route}/#{params[:upload].original_filename}"
            rec.save!
            payload = {
                files: vdm.production_dpt.prod_audios
            }
        end
        change = VdmChange.new
        change.changeDetail = "Subida de meterial bruto #{params[:file_type]}"
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.department = 'produccion'
        change.save!
        FileUtils.remove_dir dir, true
      end
    end
    render :json => { data: payload, status: 'SUCCESS'}, :status => 200
  end

  private

  def set_vdm
    @vdm = Vdm.find(params[:id])
  end

  def vdm_params
    params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description, :document_data => [])
  end
end