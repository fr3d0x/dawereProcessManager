require 'test_helper'

class ProductionDptsControllerTest < ActionController::TestCase
  setup do
    @production_dpt = production_dpts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:production_dpts)
  end

  test "should create production_dpt" do
    assert_difference('ProductionDpt.count') do
      post :create, production_dpt: { comments: @production_dpt.comments, conclu: @production_dpt.conclu, intro: @production_dpt.intro, script: @production_dpt.script, status: @production_dpt.status, vidDev: @production_dpt.vidDev }
    end

    assert_response 201
  end

  test "should show production_dpt" do
    get :show, id: @production_dpt
    assert_response :success
  end

  test "should update production_dpt" do
    put :update, id: @production_dpt, production_dpt: { comments: @production_dpt.comments, conclu: @production_dpt.conclu, intro: @production_dpt.intro, script: @production_dpt.script, status: @production_dpt.status, vidDev: @production_dpt.vidDev }
    assert_response 204
  end

  test "should destroy production_dpt" do
    assert_difference('ProductionDpt.count', -1) do
      delete :destroy, id: @production_dpt
    end

    assert_response 204
  end
end
