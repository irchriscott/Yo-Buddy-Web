require 'test_helper'

class BorrowMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get borrow_messages_index_url
    assert_response :success
  end

  test "should get new" do
    get borrow_messages_new_url
    assert_response :success
  end

  test "should get create" do
    get borrow_messages_create_url
    assert_response :success
  end

  test "should get destroy" do
    get borrow_messages_destroy_url
    assert_response :success
  end

end
