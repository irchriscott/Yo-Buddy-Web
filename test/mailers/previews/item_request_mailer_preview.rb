# Preview all emails at http://localhost:3000/rails/mailers/item_request_mailer
class ItemRequestMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/item_request_mailer/suggest
  def suggest
    ItemRequestMailer.suggest
  end

  # Preview this email at http://localhost:3000/rails/mailers/item_request_mailer/update_suggestion
  def update_suggestion
    ItemRequestMailer.update_suggestion
  end

  # Preview this email at http://localhost:3000/rails/mailers/item_request_mailer/update_suggestion_status
  def update_suggestion_status
    ItemRequestMailer.update_suggestion_status
  end

  # Preview this email at http://localhost:3000/rails/mailers/item_request_mailer/update_request
  def update_request
    ItemRequestMailer.update_request
  end

end
