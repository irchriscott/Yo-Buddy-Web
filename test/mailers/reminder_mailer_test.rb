require 'test_helper'

class ReminderMailerTest < ActionMailer::TestCase
  test "bring_item" do
    mail = ReminderMailer.bring_item
    assert_equal "Bring item", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "pick_item" do
    mail = ReminderMailer.pick_item
    assert_equal "Pick item", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "return_item" do
    mail = ReminderMailer.return_item
    assert_equal "Return item", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
