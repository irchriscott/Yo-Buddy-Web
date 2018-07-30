# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer
class ReminderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/bring_item
  def bring_item
    ReminderMailer.bring_item
  end

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/pick_item
  def pick_item
    ReminderMailer.pick_item
  end

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/return_item
  def return_item
    ReminderMailer.return_item
  end

end
