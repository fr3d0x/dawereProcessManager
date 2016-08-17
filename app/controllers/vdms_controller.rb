class VdmsController < ApplicationController
  before_action :set_vdm, only: [:show, :update, :destroy]
  before_action :authenticate
  before_action :only => [:addVdm] {validateRole([Roles::SUPER, Roles::CONTENT_LEADER],$currentPetitionUser)}
  include ActionView::Helpers::TextHelper


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

  def getVdmsBySubject
    if params[:id] != nil
      sp = SubjectPlanification.find_by_subject_id(params[:id])
      i = 0
      payload = []
      productionPayload = []
      productManagementPayload = []
      employees = []
      productionDept = {}
      designPayload = []
      designDept = {}
      productionStatus = 'no asignado'
      editionStatus = 'no asignado'
      designStatus = 'no asignado'
      postProdStatus = 'no asignado'
      sp.classes_planifications.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |cp|
        cp.vdms.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |vdm|
          if vdm.production_dpt != nil
            prodDeptResponsable = 'no asignado'
            prodDeptStatus = vdm.production_dpt.status
            if vdm.production_dpt.production_dpt_assignment != nil
              prodDeptResponsable = vdm.production_dpt.production_dpt_assignment.assignedName
              editionStatus = vdm.production_dpt.production_dpt_assignment.status
              productionDept = {
                  status: vdm.production_dpt.status,
                  script: vdm.production_dpt.script,
                  comments: vdm.production_dpt.comments,
                  intro: vdm.production_dpt.intro,
                  vidDev: vdm.production_dpt.vidDev,
                  conclu: vdm.production_dpt.conclu,
                  assignment: vdm.production_dpt.production_dpt_assignment
              }
            else
              productionDept = vdm.production_dpt
            end
            introduccion = vdm.production_dpt.intro
            conclusion = vdm.production_dpt.conclu
            desarrollo = vdm.production_dpt.vidDev

            productionPayload.push({
                 id: vdm.id,
                 videoId: vdm.videoId,
                 videoTittle: vdm.videoTittle,
                 videoContent: vdm.videoContent,
                 status: vdm.status,
                 comments: vdm.comments,
                 cp: cp.as_json,
                 prodDept: productionDept,
                 intro: introduccion,
                 conclu: conclusion,
                 vidDev: desarrollo,
                 videoNumber: vdm.number,
                 prodDeptStatus: prodDeptStatus,
                 prodDeptResponsable: prodDeptResponsable
             })
          end

          if vdm.design_dpt != nil
            designResponsable = 'no asignado'
            designStatus = vdm.production_dpt.status
            if vdm.design_dpt.design_assignment != nil
              designResponsable = vdm.design_dpt.design_assignment.assignedName
              designDept = {
                  status: vdm.design_dpt.status,
                  comments: vdm.design_dpt.comments,
                  assignment: vdm.design_dpt.design_assignment
              }
            else
              designDept = vdm.design_dpt
            end
            designPayload.push({
               id: vdm.id,
               videoId: vdm.videoId,
               videoTittle: vdm.videoTittle,
               videoNumber: vdm.number,
               prodDept: productionDept,
               designDept: designDept
             })
          end
          if vdm.product_management != nil

            postpDept = {status: 'no asignado'}
=begin
            if vdm.post_production_dpt != nil
              postpDept = vdm.post_production_dpt
            end
=end
            productManagementPayload.push({
                 id: vdm.id,
                 videoId: vdm.videoId,
                 videoTittle: vdm.videoTittle,
                 videoContent: vdm.videoContent,
                 status: vdm.status,
                 comments: vdm.comments,
                 cp: cp.as_json,
                 prodDept: productionDept,
                 designDept: designDept,
                 postpDept: postpDept,
                 productionStatus: productionStatus,
                 editionStatus: editionStatus,
                 designStatus: designStatus,
                 postProdStatus: postProdStatus,
                 productManagement: vdm.product_management
             })
          end
          payload.push({
              id: vdm.id,
              videoId: vdm.videoId,
              videoTittle: vdm.videoTittle,
              videoContent: vdm.videoContent,
              status: vdm.status,
              comments: vdm.comments,
              cp: cp.as_json,
              prodDept: vdm.production_dpt,
              videoNumber: vdm.number,
              productManagement: vdm.product_management
          })
          i+=1
        end
      end
      users = User.all
      users.each do |user|
        if user.employee != nil
          employees.push({
               id: user.id,
               name: user.employee.firstName,
               lastName: user.employee.firstSurname,
               username: user.username,
               roles: user.roles
           })
        end
      end
      render :json => { data: payload, subject: sp.subject, employees: employees, production: productionPayload, productManagement: productManagementPayload, design: designPayload, status: 'SUCCESS'}, :status => 200
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
      changes = []
      script = ''
      prdPayload = nil
      prodAssignedPayload = nil
      designPayload = nil
      if vdm.videoContent != newVdm['videoContent']
        change = VdmChange.new
        change.changeDetail = "Cambio de contenido"
        if vdm.videoContent != nil
          change.changedFrom = vdm.videoContent
        else
          change.changedFrom = "vacio"
        end
        change.changedTo = newVdm['videoContent']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.department = 'pre-produccion'
        change.changeDate = Time.now
        changes.push(change)
      end
      if vdm.videoTittle != newVdm['videoTittle']
        change = VdmChange.new
        change.changeDetail = "Cambio de Titulo"
        if vdm.videoTittle != nil
          change.changedFrom = vdm.videoTittle
        else
          change.changedFrom = "vacio"
        end

        change.changedTo = newVdm['videoTittle']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.department = 'pre-produccion'
        changes.push(change)
      end

      if vdm.status != newVdm['status']
        change = VdmChange.new
        change.changeDetail = "Cambio de estado"
        change.changedFrom = vdm.status
        change.changedTo = newVdm['status']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.department = 'pre-produccion'
        changes.push(change)
        if newVdm['status'] == 'procesado'
          if vdm.classes_planification.subject_planification.firstPeriodCompleted == false
            vdmsFromFirstPeriod = Vdm.find_by_sql("Select v.* from vdms v, classes_planifications cp, subject_planifications sp where sp.id = " + vdm.classes_planification.subject_planification.id.to_s + " and cp.subject_planification_id = sp.id and cp.period = 1 and v.classes_planification_id = cp.id")
            vdmsProcessed = Vdm.find_by_sql("Select v.* from vdms v, classes_planifications cp, subject_planifications sp where sp.id = " + vdm.classes_planification.subject_planification.id.to_s + "and cp.subject_planification_id = sp.id and v.status = 'procesado' and v.classes_planification_id = cp.id")
            if checkFirstPeriodProcessed(vdmsFromFirstPeriod, newVdm, vdm)
              productionDpt = []
              vdmsEmail = []
              vdm.classes_planification.subject_planification.firstPeriodCompleted = true
              vdmsProcessed.each do |v|
                pdpt = ProductionDpt.new
                pdpt.status = 'asignado'
                pdpt.vdm_id = v.id
                productionDpt.push(pdpt)
                vdmsEmail.push(v)
              end
              #Agrego a la lista el que traigo del frontEnd que no esta en BD
              pdpt = ProductionDpt.new
              pdpt.status = 'asignado'
              pdpt.vdm_id = newVdm['id']
              productionDpt.push(pdpt)
              vdmsEmail.push(newVdm)
              ProductionDpt.transaction do
                productionDpt.each(&:save!)
              end
              UserNotifier.send_assigned_to_production(vdmsEmail).deliver
            end
          else
            production_dpt = ProductionDpt.new
            production_dpt.status = 'asignado'
            production_dpt.vdm_id = newVdm['id']
            production_dpt.save!
            UserNotifier.send_assigned_to_production(vdm).deliver
          end
          vdm.classes_planification.subject_planification.save!
        end
      end
      if vdm.comments != newVdm['comments']
        change = VdmChange.new
        change.changeDetail = "Cambio de comentarios"
        if vdm.videoTittle != nil
          change.changedFrom = vdm.videoTittle
        else
          change.changedFrom = "vacio"
        end
        change.changedTo = newVdm['videoTittle']
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
      if newVdm['prodDept'] != nil
        prodDeptChanges = []
        script = 'guardado'
        if vdm.production_dpt != nil
          if vdm.production_dpt.comments != newVdm['prodDept']['comments']
            change = VdmChange.new
            change.changeDetail = "Cambio de comentarios de produccion"
            if vdm.production_dpt.comments != nil
              change.changedFrom = vdm.production_dpt.comments
            else
              change.changedFrom = "vacio"
            end
            change.changedTo = newVdm['prodDept']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
          end

          if vdm.production_dpt.script != newVdm['prodDept']['script']
            if newVdm['prodDept']['script'].length > 10
              change = VdmChange.new
              change.changeDetail = "Cambio de Guion de produccion"
              if vdm.production_dpt.comments != nil
                change.changedFrom = vdm.production_dpt.script
              else
                change.changedFrom = "vacio"
              end
              change.changedTo = newVdm['prodDept']['script']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'produccion'
              prodDeptChanges.push(change)
              script = 'cambiado'
            end
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "Grabacion completa"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.comments = 'Se grabo el video completo'
            change.changeDate = Time.now
            change.department = 'produccion'
            vdm.production_dpt.status = 'grabado'
            if vdm.production_dpt.production_dpt_assignment != nil && vdm.production_dpt.production_dpt_assignment.user_id != nil
              vdm.production_dpt.production_dpt_assignment.status = 'asignado'
              vdm.production_dpt.production_dpt_assignment.save!
            else
              assignment = ProductionDptAssignment.new
              assignment.production_dpt_id = vdm.production_dpt.id
              assignment.status = 'asignado'
              assignment.save!
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
            prodDeptChanges.push(change)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro y conclucion"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)
          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro y desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo conclusion y desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] != vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo desarrollo"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)

          end
          if newVdm['intro'] != vdm.production_dpt.intro && newVdm['conclu'] == vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo intro"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)

          end
          if newVdm['intro'] == vdm.production_dpt.intro && newVdm['conclu'] != vdm.production_dpt.conclu && newVdm['vidDev'] == vdm.production_dpt.vidDev
            change = VdmChange.new
            change.changeDetail = "se grabo solo conclusion"
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            if newVdm['prodDept']['justification'] != nil
              change.comments = newVdm['prodDept']['justification']
            end
            change.changeDate = Time.now
            change.department = 'produccion'
            prodDeptChanges.push(change)
            checkForCompleteRecording(newVdm['intro'], newVdm['conclu'], newVdm['vidDev'], vdm, prodDeptChanges)
          end
          if newVdm['asigned'] != nil
            if vdm.production_dpt.production_dpt_assignment != nil
              if vdm.production_dpt.production_dpt_assignment.user_id == nil
                vdm.production_dpt.production_dpt_assignment.user_id = newVdm['asigned']['id']
                vdm.production_dpt.production_dpt_assignment.assignedName = newVdm['asigned']['name'] + ' ' + newVdm['asigned']['lastName']
                vdm.production_dpt.production_dpt_assignment.status = 'asignado'
                vdm.production_dpt.production_dpt_assignment.save!
              end
              prodAssignedPayload = {
                  id: vdm.production_dpt.production_dpt_assignment.id,
                  assignedName: vdm.production_dpt.production_dpt_assignment.assignedName,
                  status: vdm.production_dpt.production_dpt_assignment.status,
                  user_id: vdm.production_dpt.production_dpt_assignment.user_id
              }
            end
          end
          if newVdm['prodDept']['assignment'] != nil
            if vdm.production_dpt.production_dpt_assignment.comments != newVdm['prodDept']['assignment']['comments']
              change = VdmChange.new
              change.changeDetail = "Cambio de comentarios de editor"
              if vdm.production_dpt.production_dpt_assignment.comments != nil
                change.changedFrom = vdm.production_dpt.production_dpt_assignment.comments
              else
                change.changedFrom = "vacio"
              end
              change.changedTo = newVdm['prodDept']['assignment']['comments']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'edicion'
              prodDeptChanges.push(change)
            end
            if vdm.production_dpt.production_dpt_assignment.status != newVdm['prodDept']['assignment']['status']
              if newVdm['prodDept']['assignment']['status'] != 'no asignado'
                change = VdmChange.new
                change.changeDetail = "Cambio de estado de editor"
                if vdm.production_dpt.production_dpt_assignment.status != nil
                  change.changedFrom = vdm.production_dpt.production_dpt_assignment.status
                else
                  change.changedFrom = "vacio"
                end
                change.changedTo = newVdm['prodDept']['assignment']['status']
                change.vdm_id = vdm.id
                change.user_id = $currentPetitionUser['id']
                change.uname = $currentPetitionUser['username']
                change.videoId = vdm.videoId
                change.changeDate = Time.now
                change.department = 'edicion'
                prodDeptChanges.push(change)
              end
            end
            vdm.production_dpt.production_dpt_assignment.comments = newVdm['prodDept']['assignment']['comments']
            if newVdm['prodDept']['assignment']['status'] != 'no asignado'
              vdm.production_dpt.production_dpt_assignment.status = newVdm['prodDept']['assignment']['status']
            end
            vdm.production_dpt.production_dpt_assignment.save!
            prodAssignedPayload = vdm.production_dpt.production_dpt_assignment
          end
          vdm.production_dpt.comments = newVdm['prodDept']['comments']
          if newVdm['prodDept']['script'] != nil && newVdm['prodDept']['script'].length > 10
            vdm.production_dpt.script = newVdm['prodDept']['script']
          end
          vdm.production_dpt.intro = newVdm['intro']
          vdm.production_dpt.conclu = newVdm['conclu']
          vdm.production_dpt.vidDev = newVdm['vidDev']
          vdm.production_dpt.save!
          VdmChange.transaction do
            prodDeptChanges.uniq.each(&:save!)
          end
        end
        prdPayload = {
            status: vdm.production_dpt.status,
            script: script,
            comments: vdm.production_dpt.comments,
            intro: vdm.production_dpt.intro,
            conclu: vdm.production_dpt.conclu,
            vidDev: vdm.production_dpt.vidDev,
            assignment: prodAssignedPayload
        }
      end
      if newVdm['designDept'] != nil
        if newVdm['dAsigned'] != nil
          assignment = vdm.design_dpt.design_assignment
          if assignment == nil
            assignment = DesignAssignment.new
          end
          assignment.design_dpt_id = vdm.design_dpt.id
          assignment.user_id = newVdm['dAsigned']['id']
          assignment.assignedName = newVdm['dAsigned']['name'] + ' ' + newVdm['dAsigned']['lastName']
          assignment.status = 'asignado'
          assignment.save!
        end
        designPayload = {
            status: vdm.design_dpt.status,
            comments: vdm.design_dpt.comments,
            assignment: assignment
        }
      end
      vdm.videoContent = newVdm['videoContent']
      vdm.videoTittle = newVdm['videoTittle']
      vdm.status = newVdm['status']
      vdm.comments = newVdm['comments']
      vdm.save

      payload = {
          cp: vdm.classes_planification,
          videoId: vdm.videoId,
          videoTittle: vdm.videoTittle,
          videoContent: vdm.videoContent,
          status: vdm.status,
          comments: vdm.comments,
          subject: vdm.classes_planification.subject_planification.subject,
          prodDept: prdPayload,
          designDept: designPayload

      }
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end

  def checkForCompleteRecording(intro, vidDev, conclu, vdm, array)
    if intro == true && conclu == true && vidDev == true
      change = VdmChange.new
      change.changeDetail = "Grabacion completa"
      change.vdm_id = vdm.id
      change.user_id = $currentPetitionUser['id']
      change.uname = $currentPetitionUser['username']
      change.videoId = vdm.videoId
      change.comments = 'Se grabo el video completo'
      change.changeDate = Time.now
      change.department = 'produccion'
      vdm.production_dpt.status = 'grabado'
      if vdm.production_dpt.production_dpt_assignment != nil && vdm.production_dpt.production_dpt_assignment.user_id != nil
        vdm.production_dpt.production_dpt_assignment.status = 'asignado'
        vdm.production_dpt.production_dpt_assignment.save!
      else
        assignment = ProductionDptAssignment.new
        assignment.production_dpt_id = vdm.production_dpt.id
        assignment.status = 'asignado'
        assignment.save!
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
            design = DesignDpt.new
            design.status = 'asignado'
            design.vdm = vdm
            design.design_assignment = DesignAssignment.new
            design.design_assignment.status = 'no asignado'
            design.save!
            if params['role'] == 'productManager'
              if vdm.product_management != nil
                vdm.product_management.editionStatus = 'aprobado'
                vdm.product_management.save!
              end
            else
              if vdm.product_management != nil
                vdm.product_management.editionStatus = 'por aprobar'
                vdm.product_management.save!
              end
            end

            payload = {
                editionStatus: vdm.production_dpt.production_dpt_assignment.status,
                productManagement: vdm.product_management

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
            prdPayload = {
                status: vdm.production_dpt.status,
                comments: vdm.production_dpt.comments,
                intro: vdm.production_dpt.intro,
                conclu: vdm.production_dpt.conclu,
                vidDev: vdm.production_dpt.vidDev,
                assignment: vdm.production_dpt.production_dpt_assignment
            }
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                prodDept: prdPayload,
                productManagement: vdm.product_management
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
            if vdm.product_management != nil
              vdm.product_management.editionStatus = 'rechazado'
              vdm.product_management.designStatus = nil
              vdm.product_management.postProductionStatus = nil
              vdm.product_management.save!
            end
            prdPayload = {
                status: vdm.production_dpt.status,
                comments: vdm.production_dpt.comments,
                intro: vdm.production_dpt.intro,
                conclu: vdm.production_dpt.conclu,
                vidDev: vdm.production_dpt.vidDev,
                assignment: vdm.production_dpt.production_dpt_assignment
            }
            payload = {
                cp: vdm.classes_planification,
                videoId: vdm.videoId,
                videoTittle: vdm.videoTittle,
                videoContent: vdm.videoContent,
                status: vdm.status,
                comments: vdm.comments,
                prodDept: prdPayload,
                productManagement: vdm.product_management
            }
          end
      end
      render :json => { data: payload, status: 'SUCCESS'}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: 'NOT FOUND'}, :status => 404
  end
  private

    def set_vdm
      @vdm = Vdm.find(params[:id])
    end

    def vdm_params
      params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description)
    end
end
