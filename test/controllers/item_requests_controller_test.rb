require 'test_helper'

class ItemRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get item_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get item_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get item_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get item_requests_create_url
    assert_response :success
  end

  test "should get edit" do
    get item_requests_edit_url
    assert_response :success
  end

  test "should get update" do
    get item_requests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get item_requests_destroy_url
    assert_response :success
  end

end
