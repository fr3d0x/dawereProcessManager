require 'test_helper'

class PostProdDptAssignmentsControllerTest < ActionController::TestCase
  setup do
    @post_prod_dpt_assignment = post_prod_dpt_assignments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:post_prod_dpt_assignments)
  end

  test "should create post_prod_dpt_assignment" do
    assert_difference('PostProdDptAssignment.count') do
      post :create, post_prod_dpt_assignment: { assignedName: @post_prod_dpt_assignment.assignedName, comments: @post_prod_dpt_assignment.comments, status: @post_prod_dpt_assignment.status }
    end

    assert_response 201
  end

  test "should show post_prod_dpt_assignment" do
    get :show, id: @post_prod_dpt_assignment
    assert_response :success
  end

  test "should update post_prod_dpt_assignment" do
    put :update, id: @post_prod_dpt_assignment, post_prod_dpt_assignment: { assignedName: @post_prod_dpt_assignment.assignedName, comments: @post_prod_dpt_assignment.comments, status: @post_prod_dpt_assignment.status }
    assert_response 204
  end

  test "should destroy post_prod_dpt_assignment" do
    assert_difference('PostProdDptAssignment.count', -1) do
      delete :destroy, id: @post_prod_dpt_assignment
    end

    assert_response 204
  end
end
