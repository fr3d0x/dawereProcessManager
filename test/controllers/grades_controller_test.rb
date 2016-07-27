require 'test_helper'

class GradesControllerTest < ActionController::TestCase
  setup do
    @grade = grades(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grades)
  end

  test "should create grade" do
    assert_difference('Grade.count') do
      post :create, grade: { description: @grade.description, name: @grade.name }
    end

    assert_response 201
  end

  test "should show grade" do
    get :show, id: @grade
    assert_response :success
  end

  test "should update grade" do
    put :update, id: @grade, grade: { description: @grade.description, name: @grade.name }
    assert_response 204
  end

  test "should destroy grade" do
    assert_difference('Grade.count', -1) do
      delete :destroy, id: @grade
    end

    assert_response 204
  end
end
