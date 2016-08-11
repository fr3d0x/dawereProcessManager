require 'test_helper'

class ProductManagementsControllerTest < ActionController::TestCase
  setup do
    @product_management = product_managements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:product_managements)
  end

  test "should create product_management" do
    assert_difference('ProductManagement.count') do
      post :create, product_management: { designStatus: @product_management.designStatus, editionStatus: @product_management.editionStatus, postProductionStatus: @product_management.postProductionStatus, productionStatus: @product_management.productionStatus }
    end

    assert_response 201
  end

  test "should show product_management" do
    get :show, id: @product_management
    assert_response :success
  end

  test "should update product_management" do
    put :update, id: @product_management, product_management: { designStatus: @product_management.designStatus, editionStatus: @product_management.editionStatus, postProductionStatus: @product_management.postProductionStatus, productionStatus: @product_management.productionStatus }
    assert_response 204
  end

  test "should destroy product_management" do
    assert_difference('ProductManagement.count', -1) do
      delete :destroy, id: @product_management
    end

    assert_response 204
  end
end
