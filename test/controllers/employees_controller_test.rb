require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    @employee = employees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:employees)
  end

  test "should create employee" do
    assert_difference('Employee.count') do
      post :create, employee: { address: @employee.address, admissionDate: @employee.admissionDate, birthDate: @employee.birthDate, cellphone: @employee.cellphone, currentSalary: @employee.currentSalary, email2: @employee.email2, email: @employee.email, firstName: @employee.firstName, firstSurname: @employee.firstSurname, jobTittle: @employee.jobTittle, personalId: @employee.personalId, phone: @employee.phone, rif: @employee.rif, secondSurname: @employee.secondSurname }
    end

    assert_response 201
  end

  test "should show employee" do
    get :show, id: @employee
    assert_response :success
  end

  test "should update employee" do
    put :update, id: @employee, employee: { address: @employee.address, admissionDate: @employee.admissionDate, birthDate: @employee.birthDate, cellphone: @employee.cellphone, currentSalary: @employee.currentSalary, email2: @employee.email2, email: @employee.email, firstName: @employee.firstName, firstSurname: @employee.firstSurname, jobTittle: @employee.jobTittle, personalId: @employee.personalId, phone: @employee.phone, rif: @employee.rif, secondSurname: @employee.secondSurname }
    assert_response 204
  end

  test "should destroy employee" do
    assert_difference('Employee.count', -1) do
      delete :destroy, id: @employee
    end

    assert_response 204
  end
end
