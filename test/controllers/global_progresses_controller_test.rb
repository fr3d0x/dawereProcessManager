require 'test_helper'

class GlobalProgressesControllerTest < ActionController::TestCase
  setup do
    @global_progress = global_progresses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:global_progresses)
  end

  test "should create global_progress" do
    assert_difference('GlobalProgress.count') do
      post :create, global_progress: {  }
    end

    assert_response 201
  end

  test "should show global_progress" do
    get :show, id: @global_progress
    assert_response :success
  end

  test "should update global_progress" do
    put :update, id: @global_progress, global_progress: {  }
    assert_response 204
  end

  test "should destroy global_progress" do
    assert_difference('GlobalProgress.count', -1) do
      delete :destroy, id: @global_progress
    end

    assert_response 204
  end
end
