require 'test_helper'

class AdminUserControllerTest < ActionDispatch::IntegrationTest
  test "should get signin" do
    get admin_user_controller_signin_url
    assert_response :success
  end

  test "should get index" do
    get admin_user_controller_index_url
    assert_response :success
  end

  test "should get items" do
    get admin_user_controller_items_url
    assert_response :success
  end

  test "should get borrows" do
    get admin_user_controller_borrows_url
    assert_response :success
  end

end
