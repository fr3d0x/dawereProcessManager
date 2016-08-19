require 'test_helper'

class PostProdDptsControllerTest < ActionController::TestCase
  setup do
    @post_prod_dpt = post_prod_dpts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:post_prod_dpts)
  end

  test "should create post_prod_dpt" do
    assert_difference('PostProdDpt.count') do
      post :create, post_prod_dpt: { comments: @post_prod_dpt.comments, status: @post_prod_dpt.status }
    end

    assert_response 201
  end

  test "should show post_prod_dpt" do
    get :show, id: @post_prod_dpt
    assert_response :success
  end

  test "should update post_prod_dpt" do
    put :update, id: @post_prod_dpt, post_prod_dpt: { comments: @post_prod_dpt.comments, status: @post_prod_dpt.status }
    assert_response 204
  end

  test "should destroy post_prod_dpt" do
    assert_difference('PostProdDpt.count', -1) do
      delete :destroy, id: @post_prod_dpt
    end

    assert_response 204
  end
end
