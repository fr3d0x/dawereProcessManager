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
      employees = []
      sp.classes_planifications.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |cp|
        cp.vdms.reject{ |r| r.status == 'DESTROYED' }.uniq.each do |vdm|
          if vdm.production_dpt != nil
            prodDeptResponsable = 'no asignado'
            prodDeptStatus = vdm.production_dpt.status
            if vdm.production_dpt.production_dpt_assignment != nil
              prodDeptResponsable = vdm.production_dpt.production_dpt_assignment.assignedName
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
                 prodDept: vdm.production_dpt,
                 prodAssignment: vdm.production_dpt.production_dpt_assignment,
                 intro: introduccion,
                 conclu: conclusion,
                 vidDev: desarrollo,
                 videoNumber: vdm.number,
                 prodDeptStatus: prodDeptStatus,
                 prodDeptResponsable: prodDeptResponsable
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
      render :json => { data: payload, subject: sp.subject, employees: employees, production: productionPayload, status: 'SUCCESS'}, :status => 200
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
      prdPayload = {}
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
            UserNotifier.send_assigned_to_production(newVdm).deliver
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
            prodDeptChanges.push(change)
          end

          if vdm.production_dpt.script != newVdm['prodDept']['script']
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
            prodDeptChanges.push(change)
            script = 'cambiado'
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
            vdm.production_dpt.status = 'grabado'
            assignment = ProductionDptAssignment.new
            assignment.production_dpt_id = vdm.production_dpt.id
            assignment.status = 'no asignado'
            assignment.save!
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
            end
          end
          vdm.production_dpt.comments = newVdm['prodDept']['comments']
          vdm.production_dpt.script = newVdm['prodDept']['script']
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
            vidDev: vdm.production_dpt.vidDev
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
          prodDept: prdPayload

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
      vdm.production_dpt.status = 'grabado'
      assignment = ProductionDptAssignment.new
      assignment.production_dpt_id = vdm.production_dpt.id
      assignment.status = 'no asignado'
      assignment.save!
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

  private

    def set_vdm
      @vdm = Vdm.find(params[:id])
    end

    def vdm_params
      params.require(:vdm).permit(:videoId, :videoTittle, :videoContent, :status, :comments, :description)
    end
end
