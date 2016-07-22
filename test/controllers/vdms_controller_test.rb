require 'test_helper'

class VdmsControllerTest < ActionController::TestCase
  setup do
    @vdm = vdms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vdms)
  end

  test "should create vdm" do
    assert_difference('Vdm.count') do
      post :create, vdm: { Description: @vdm.Description, coments: @vdm.coments, status: @vdm.status, videoContent: @vdm.videoContent, videoId: @vdm.videoId, videoTittle: @vdm.videoTittle }
    end

    assert_response 201
  end

  test "should show vdm" do
    get :show, id: @vdm
    assert_response :success
  end

  test "should update vdm" do
    put :update, id: @vdm, vdm: { Description: @vdm.Description, coments: @vdm.coments, status: @vdm.status, videoContent: @vdm.videoContent, videoId: @vdm.videoId, videoTittle: @vdm.videoTittle }
    assert_response 204
  end

  test "should destroy vdm" do
    assert_difference('Vdm.count', -1) do
      delete :destroy, id: @vdm
    end

    assert_response 204
  end
end
