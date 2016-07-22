require 'test_helper'

class SubjectPlanificationsControllerTest < ActionController::TestCase
  setup do
    @subject_planification = subject_planifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subject_planifications)
  end

  test "should create subject_planification" do
    assert_difference('SubjectPlanification.count') do
      post :create, subject_planification: { status: @subject_planification.status, subjectId: @subject_planification.subjectId, teacherId: @subject_planification.teacherId }
    end

    assert_response 201
  end

  test "should show subject_planification" do
    get :show, id: @subject_planification
    assert_response :success
  end

  test "should update subject_planification" do
    put :update, id: @subject_planification, subject_planification: { status: @subject_planification.status, subjectId: @subject_planification.subjectId, teacherId: @subject_planification.teacherId }
    assert_response 204
  end

  test "should destroy subject_planification" do
    assert_difference('SubjectPlanification.count', -1) do
      delete :destroy, id: @subject_planification
    end

    assert_response 204
  end
end
