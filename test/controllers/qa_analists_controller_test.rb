require 'test_helper'

class QaAnalistsControllerTest < ActionController::TestCase
  setup do
    @qa_analist = qa_analists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:qa_analists)
  end

  test "should create qa_analist" do
    assert_difference('QaAnalist.count') do
      post :create, qa_analist: {  }
    end

    assert_response 201
  end

  test "should show qa_analist" do
    get :show, id: @qa_analist
    assert_response :success
  end

  test "should update qa_analist" do
    put :update, id: @qa_analist, qa_analist: {  }
    assert_response 204
  end

  test "should destroy qa_analist" do
    assert_difference('QaAnalist.count', -1) do
      delete :destroy, id: @qa_analist
    end

    assert_response 204
  end
end
