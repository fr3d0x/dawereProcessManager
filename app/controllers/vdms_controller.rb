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
                if vdm.production_dpt != nil
                  if vdm.production_dpt.status != nil && vdm.production_dpt.status != ''
                    payload_item['status']  = vdm.production_dpt.status
                  end
                  responsable = 'no asignado'
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
                      screen_play_name: vdm.production_dpt.screen_play_name
                  }
                  if vdm.production_dpt.production_dpt_assignment != nil
                    responsable = vdm.production_dpt.production_dpt_assignment.assignedName
                    production_dpt['assignment'] = vdm.production_dpt.production_dpt_assignment
                  end
                  payload_item['intro'] = vdm.production_dpt.intro
                  payload_item['conclu'] = vdm.production_dpt.conclu
                  payload_item['vidDev'] = vdm.production_dpt.vidDev
                  payload_item['prodDeptStatus'] = vdm.production_dpt.status
                  payload_item['prodDeptResponsable'] = responsable
                  payload_item['prodDept'] = production_dpt
                end
              when 'designLeader', 'designer'
                if vdm.design_dpt != nil
                  design_dpt = {
                      id: vdm.design_dpt.id,
                      status: vdm.design_dpt.status,
                      comments: vdm.design_dpt.comments,
                  }
                  if vdm.design_dpt.design_assignment != nil
                    design_dpt['assignment'] = vdm.design_dpt.design_assignment
                  end
                  payload_item['prodDept'] = vdm.production_dpt
                  payload_item['designDept'] = design_dpt
                end
              when 'postProLeader', 'post-producer'
                if vdm.post_prod_dpt != nil
                  post_prod_dpt = {
                      id: vdm.post_prod_dpt.id,
                      status: vdm.post_prod_dpt.status,
                      comments: vdm.post_prod_dpt.comments,
                  }
                  if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                    post_prod_dpt['assignment'] = vdm.post_prod_dpt.post_prod_dpt_assignment
                  end
                  payload_item['prodDept'] = vdm.production_dpt
                  payload_item['designDept'] = vdm.design_dpt
                  payload_item['postProdDept'] = post_prod_dpt
                end
              when 'productManager'
                if vdm.product_management != nil
                  payload_item['prodDept'] = vdm.production_dpt
                  payload_item['designDept'] = vdm.design_dpt
                  payload_item['postProdDept'] = vdm.post_prod_dpt
                  payload_item['productManagement'] = vdm.product_management
                  payload_item['productionStatus'] = vdm.production_dpt.status
                  if vdm.production_dpt != nil && vdm.production_dpt.production_dpt_assignment != nil
                    payload_item['editionStatus'] = vdm.production_dpt.production_dpt_assignment.status
                  else
                    payload_item['editionStatus'] = 'no asignado'
                  end
                  payload_item['designStatus'] = vdm.design_dpt.status
                  payload_item['postProdStatus'] = vdm.post_prod_dpt.status
                end
              when 'qa', 'qaAnalist'
                if vdm.qa_dpt != nil
                  responsable = 'no asignado'
                  qa_dept = {
                      id: vdm.qa_dpt.id,
                      status: vdm.qa_dpt.status,
                      comments: vdm.qa_dpt.comments,
                  }
                  if vdm.qa_dpt.qa_analist != nil
                    responsable = vdm.qa_dpt.qa_analist.assignedName
                    qa_dept['assignment'] = vdm.qa_dpt.qa_analist
                  end
                  payload_item['qaDept'] = qa_dept
                  payload_item['qaResponsable'] = responsable
                end
              else
                raise Exceptions::InvalidRoleException
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

      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          subject: vdm.classes_planification.subject_planification.subject,
          changes: vdm.vdm_changes,
          prodDept: vdm.production_dpt
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
      case newVdm['role']
        when 'contentLeader', 'contentAnalist'
          update_pre_prod_content(vdm, newVdm)
        when 'production', 'editor'
          prd_payload = ProductionDptsController.update_production_content(vdm, newVdm)
        when 'designLeader', 'designer'
          design_payload = DesignDptController.update_design_changes(vdm, newVdm)
        when 'postProLeader', 'post-producer'
          post_prod_payload = PostProdDptsController.update_post_prod_content(vdm, newVdm)
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
          postProdDept: post_prod_payload
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
            assignment = design_dpt.design__assignment
            if  assignment == nil
              assignment = DesignAssignment.new
            end
            user = assign_task_to('designer')
            assignment.user_id = user.id
            assignment.status = 'asignado'
            assignment.assignedName = u.employee.firstName + ' ' + u.employee.firstSurname
            assignment.design_dpt_id = design_dpt.id
            assignment.save!
            UserNotifier.send_assigned_to_designLeader(vdm).deliver
            UserNotifier.create_send_assigned_to_designer(vdm, user).deliver
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

    if new_vdm['class_doc']
      change = VdmChange.new
      change.changeDetail = 'Cambio de documento'
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      vdm.classDoc = new_vdm['class_doc']['base64'] #create a document associated with the item that has just been created end
      vdm.class_doc_name = new_vdm['class_doc']['filename']
      change.changedTo = vdm.classDoc
      changes.push(change)
      FileUtils.cp(vdm.classDoc.path, $files_copy_route+'/'+new_vdm['class_doc']['filename'])
    end
    if new_vdm['teacher_files']
      change = VdmChange.new
      change.changeDetail = 'Creacion de material de profesor'

      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.changeDate = Time.now
      change.department = 'pre-produccion'
      changes.push(change)
      teacher_files = []
      new_vdm['teacher_files'].each do |tf|
        file = TeacherFile.new
        file.file = tf['base64']
        file.vdm_id = vdm.id
        file.file_name = tf['filename']
        teacher_files.push(file)
        FileUtils.cp(file.file.path, $files_copy_route+'/'+tf['filename'])
      end
      if teacher_files.count >= 1
        TeacherFile.transaction do
          teacher_files.each(&:save!)
        end
      end

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
              if vdm.product_management != nil
                vdm.product_management.productionStatus = 'aprobado'
                vdm.product_management.editionStatus = 'aprobado'
                vdm.product_management.designStatus = 'asignado'
                vdm.product_management.save!
                UserNotifier.send_approved_to_editor(vdm, vdm.production_dpt.production_dpt_assignment.user.employee).deliver
                design = vdm.design_dpt
                if design == nil
                  design = DesignDpt.new
                end
                design.status = 'asignado'
                design.vdm = vdm
                design.save!
                UserNotifier.send_assigned_to_designLeader(vdm).deliver
                if design.design_assignment != nil
                  design.design_assignment.status = 'asignado'
                  design.design_assignment.save!
                end
              end
            else
              if vdm.product_management != nil
                vdm.product_management.editionStatus = 'por aprobar'
                vdm.product_management.save!
                UserNotifier.send_to_approved_to_product_Manager(vdm, 'Edicion').deliver
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
              if vdm.product_management != nil
                vdm.product_management.designStatus = 'aprobado'
                vdm.product_management.postProductionStatus = 'asignado'
                vdm.product_management.save!
              end
              postProd = vdm.post_prod_dpt
              if postProd == nil
                postProd = PostProdDpt.new
              end
              postProd.status = 'asignado'
              postProd.vdm = vdm
              postProd.save!
              if postProd.post_prod_dpt_assignment != nil
                postProd.post_prod_dpt_assignment.status = 'asignado'
                postProd.post_prod_dpt_assignment.save!
                UserNotifier.send_assigned_to_post_prod_leader(vdm).deliver
              end
            else
              if vdm.design_dpt.design_assignment != nil
                vdm.design_dpt.design_assignment.status = 'aprobado'
                designAsignmentStatus = 'aprobado'
                vdm.design_dpt.design_assignment.save!
                UserNotifier.send_approved_to_designer(vdm, vdm.design_dpt.design_assignment.user.employee).deliver
                if vdm.product_management != nil
                  vdm.product_management.designStatus = 'por aprobar'
                  vdm.product_management.save!
                  UserNotifier.send_to_approved_to_product_Manager(vdm, 'Diseño').deliver
                end
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
          pmanagement = {}
          if vdm.post_prod_dpt != nil
            if params['role'] == 'productManager'
              vdm.post_prod_dpt.status = 'aprobado'
              vdm.post_prod_dpt.save!
              UserNotifier.send_approved_to_post_prod_leader(vdm).deliver
              postProdStatus = 'aprobado'
              if vdm.product_management != nil
                vdm.product_management.postProductionStatus = 'aprobado'
                vdm.product_management.save!
              end
              qa = vdm.qa_dpt
              if vdm.qa_dpt == nil
                qa = QaDpt.new
              end
              qa.status = 'asignado'
              qa.vdm_id = vdm.id
              qa.save!
            else
              if vdm.post_prod_dpt.post_prod_dpt_assignment != nil
                vdm.post_prod_dpt.post_prod_dpt_assignment.status = 'aprobado'
                vdm.post_prod_dpt.post_prod_dpt_assignment.save!
                UserNotifier.send_approved_to_post_producer(vdm, vdm.post_prod_dpt.post_prod_dpt_assignment.user.employee).deliver
                postProdAssignmentStatus = 'aprobado'
                vdm.design_dpt.design_assignment.save!
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
      vdm = Vdm.find(params['vdmId'])
      case params['rejection']
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
                postProdDept: postProdPayload
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
                postProdDept: postProdPayload
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
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                designDept: designPayload,
                postProdDept: postProdPayload,
                productManagement: vdm.product_management
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
                productManagement: vdm.product_management
            }
          end
      end
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def self.assign_task_to(department)
    assignments = nil
    employee = nil
    users = User.joins(:roles).where(:roles => {:role => department})
    users.each do |u|
      case department
        when 'editor'
          if assignments == nil
            assignments = u.production_dpt_assignments.count
          else
            if u.production_dpt_assignments.count <= assignments
              employee = u
            end
          end
        when 'designer'
          if assignments == nil
            assignments = u.design_assignments.count
          else
            if u.design_assignments.count <= assignments
              employee = u
            end
          end
        when 'post-producer'
          if assignments == nil
            assignments = u.post_prod_dpt_assignments.count
          else
            if u.post_prod_dpt_assignments.count <= assignments
              employee = u
            end
          end
      end
    end
    return employee
  end


  private

  def set_vdm
    @vdm = Vdm.find(params[:id])
  end

  def vdm_params
    params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description, :document_data => [])
  end
end