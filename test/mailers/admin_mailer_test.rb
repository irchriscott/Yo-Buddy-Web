require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  test "register_admin_user" do
    mail = AdminMailer.register_admin_user
    assert_equal "Register admin user", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
