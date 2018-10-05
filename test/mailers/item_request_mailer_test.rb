require 'test_helper'

class ItemRequestMailerTest < ActionMailer::TestCase
  test "suggest" do
    mail = ItemRequestMailer.suggest
    assert_equal "Suggest", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "update_suggestion" do
    mail = ItemRequestMailer.update_suggestion
    assert_equal "Update suggestion", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "update_suggestion_status" do
    mail = ItemRequestMailer.update_suggestion_status
    assert_equal "Update suggestion status", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "update_request" do
    mail = ItemRequestMailer.update_request
    assert_equal "Update request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
