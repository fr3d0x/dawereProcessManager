require 'test_helper'

class VdmChangesControllerTest < ActionController::TestCase
  setup do
    @vdm_change = vdm_changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vdm_changes)
  end

  test "should create vdm_change" do
    assert_difference('VdmChange.count') do
      post :create, vdm_change: { changeDate: @vdm_change.changeDate, changeDetail: @vdm_change.changeDetail, changedFrom: @vdm_change.changedFrom, changedTo: @vdm_change.changedTo }
    end

    assert_response 201
  end

  test "should show vdm_change" do
    get :show, id: @vdm_change
    assert_response :success
  end

  test "should update vdm_change" do
    put :update, id: @vdm_change, vdm_change: { changeDate: @vdm_change.changeDate, changeDetail: @vdm_change.changeDetail, changedFrom: @vdm_change.changedFrom, changedTo: @vdm_change.changedTo }
    assert_response 204
  end

  test "should destroy vdm_change" do
    assert_difference('VdmChange.count', -1) do
      delete :destroy, id: @vdm_change
    end

    assert_response 204
  end
end
