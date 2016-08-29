require 'test_helper'

class QaDptsControllerTest < ActionController::TestCase
  setup do
    @qa_dpt = qa_dpts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:qa_dpts)
  end

  test "should create qa_dpt" do
    assert_difference('QaDpt.count') do
      post :create, qa_dpt: { comments: @qa_dpt.comments, status: @qa_dpt.status }
    end

    assert_response 201
  end

  test "should show qa_dpt" do
    get :show, id: @qa_dpt
    assert_response :success
  end

  test "should update qa_dpt" do
    put :update, id: @qa_dpt, qa_dpt: { comments: @qa_dpt.comments, status: @qa_dpt.status }
    assert_response 204
  end

  test "should destroy qa_dpt" do
    assert_difference('QaDpt.count', -1) do
      delete :destroy, id: @qa_dpt
    end

    assert_response 204
  end
end
