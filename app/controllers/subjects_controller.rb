class SubjectsController < ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]

  # GET /subjects
  # GET /subjects.json
  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def getSubjectByGrade
    if (params[:id]) != nil
      employees = []
      subjectsWuser = []
      @subjects = Subject.where(:grade_id => params[:id])
      @subjects.each do |subject|
        u = nil
        if(subject.user != nil)
          u = { id: subject.user.id,
                name: subject.user.employee.firstName + ' ' + subject.user.employee.firstSurname,
                username: subject.user.username
          }
        end

        subjectsWuser.push({
            id: subject.id,
            name: subject.name,
            grade_id: subject.grade.id,
            user: u
         })
      end
      users = User.find_by_sql("Select u.* from users u, roles r where u.id = r.user_id and (r.role='contentAnalist' OR r.role='contentLeader') group by u.id")
      users.each do |user|
        employees.push({
            id: user.id,
            name: user.employee.firstName + ' ' + user.employee.firstSurname,
            username: user.username
             })
      end
      render json: {data: subjectsWuser, status: "SUCCESS", employees: employees}, :status => 200
    end
    rescue
      render json: {status: "NOT FOUND", msg: "No existe ID de Grado seleccionado"}, :status => 404
  end

  def createSubject
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      subject = Subject.new
      grade = Grade.find(parameters['grade']['id'])
      subject.name = parameters['subject']['name']
      subject.longDescription = parameters['subject']['longDescription']
      subject.shortDescription = parameters['subject']['shortDescription']
      subject.firstPeriodDesc = parameters['subject']['firstPeriodDesc']
      subject.secondPeriodDesc = parameters['subject']['secondPeriodDesc']
      subject.thirdPeriodDesc = parameters['subject']['thirdPeriodDesc']
      subject.grade_id = grade.id

      subject.save!

      render :json => { data: nil, status: "SUCCESS"}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: "NOT FOUND"}, :status => 404
  end

  def assignSubject
    if request.raw_post != ""
      parameters = ActiveSupport::JSON.decode(request.raw_post)
      subject = Subject.find(parameters['id'])
      user = User.find(parameters['user_id'])
      subject.user = user
      subject.save!
      subject.subject_planification.user = user
      subject.subject_planification.save!
      u = nil
      if subject.user != nil
        u = { id: subject.user.id,
              name: subject.user.employee.firstName + ' ' + subject.user.employee.firstSurname,
              username: subject.user.username
        }
      end
      s = {
          id: subject.id,
          name: subject.name,
          user: u
      }

      render :json => { data: s, status: "SUCCESS"}, :status => 200
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { data: nil, status: "NOT FOUND"}, :status => 404
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    render json: @subject
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      render json: @subject, status: :created, location: @subject
    else
      render json: @subject.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subjects/1
  # PATCH/PUT /subjects/1.json
  def update
    @subject = Subject.find(params[:id])

    if @subject.update(subject_params)
      head :no_content
    else
      render json: @subject.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy

    head :no_content
  end

  private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params.require(:subject).permit(:name, :shortDescription, :longDescription, :grade, :firstPeriodDesc, :secondPeriodDesc, :thirdPeriodDesc, :goal, :user)
    end
end
