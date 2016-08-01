require 'test_helper'

class CpChangesControllerTest < ActionController::TestCase
  setup do
    @cp_change = cp_changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cp_changes)
  end

  test "should create cp_change" do
    assert_difference('CpChange.count') do
      post :create, cp_change: { changeDate: @cp_change.changeDate, changeDetail: @cp_change.changeDetail, changedFrom: @cp_change.changedFrom, changedTo: @cp_change.changedTo, comments: @cp_change.comments, uname: @cp_change.uname }
    end

    assert_response 201
  end

  test "should show cp_change" do
    get :show, id: @cp_change
    assert_response :success
  end

  test "should update cp_change" do
    put :update, id: @cp_change, cp_change: { changeDate: @cp_change.changeDate, changeDetail: @cp_change.changeDetail, changedFrom: @cp_change.changedFrom, changedTo: @cp_change.changedTo, comments: @cp_change.comments, uname: @cp_change.uname }
    assert_response 204
  end

  test "should destroy cp_change" do
    assert_difference('CpChange.count', -1) do
      delete :destroy, id: @cp_change
    end

    assert_response 204
  end
end
