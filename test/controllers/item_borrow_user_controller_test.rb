require 'test_helper'

class ItemBorrowUserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get item_borrow_user_index_url
    assert_response :success
  end

  test "should get show" do
    get item_borrow_user_show_url
    assert_response :success
  end

  test "should get new" do
    get item_borrow_user_new_url
    assert_response :success
  end

  test "should get create" do
    get item_borrow_user_create_url
    assert_response :success
  end

  test "should get edit" do
    get item_borrow_user_edit_url
    assert_response :success
  end

  test "should get update" do
    get item_borrow_user_update_url
    assert_response :success
  end

  test "should get destroy" do
    get item_borrow_user_destroy_url
    assert_response :success
  end

end
