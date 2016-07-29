require 'test_helper'

class ClassesPlanificationsControllerTest < ActionController::TestCase
  setup do
    @classes_planification = classes_planifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classes_planifications)
  end

  test "should create classes_planification" do
    assert_difference('ClassesPlanification.count') do
      post :create, classes_planification: {meGeneralObjective: @classes_planification.meGeneralObjective, meSpecificObjective: @classes_planification.meSpecificObjective, meSpecificObjDesc: @classes_planification.meSpecificObjDesc, subjectPlanification_id: @classes_planification.subjectPlanificationId, topicName: @classes_planification.topicName, videos: @classes_planification.videos }
    end

    assert_response 201
  end

  test "should show classes_planification" do
    get :show, id: @classes_planification
    assert_response :success
  end

  test "should update classes_planification" do
    put :update, id: @classes_planification, classes_planification: {meGeneralObjective: @classes_planification.meGeneralObjective, meSpecificObjective: @classes_planification.meSpecificObjective, meSpecificObjDesc: @classes_planification.meSpecificObjDesc, subjectPlanification_id: @classes_planification.subjectPlanificationId, topicName: @classes_planification.topicName, videos: @classes_planification.videos }
    assert_response 204
  end

  test "should destroy classes_planification" do
    assert_difference('ClassesPlanification.count', -1) do
      delete :destroy, id: @classes_planification
    end

    assert_response 204
  end
end
