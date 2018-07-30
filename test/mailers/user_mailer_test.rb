require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "private_user" do
    mail = UserMailer.private
    assert_equal "Private", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
