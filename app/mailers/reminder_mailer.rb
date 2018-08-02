class ReminderMailer < ApplicationMailer

    def bring_item(borrow)
        @office = (borrow.item.user.is_private?) ? borrow.item.name : "Yo Buddy"
        @borrow = borrow
        mail to: borrow.item.user.email, subject: '[Yo Buddy] - Reminder To Bring Item'
    end

    
    def pick_item(borrow)
        @office = (borrow.item.user.is_private?) ? borrow.item.name : "Yo Buddy"
        @borrow = borrow
        mail to: borrow.user.email, subject: '[Yo Buddy] - Reminder To Pick Item'
    end

   
    def return_item(borrow)
        @office = (borrow.item.user.is_private?) ? borrow.item.name : "Yo Buddy"
        @borrow = borrow
        mail to: borrow.user.email, subject: '[Yo Buddy] - Reminder To Return Item'
    end

    def activate_key(admin)
        @admin = admin
        mail to: admin.email, subject: '[Yo Buddy] - Trial Period Ending In #{@admin.admin_user_activation.remaining} days'
    end

    def self_subscription(admin, package)
        @admin = admin
        @package = package
        mail to: admin.email, subject: '[Yo Buddy] - Trial Period Expired'
    end

    def key_expired(admin)
        @admin = admin
        mail to: admin.email, subject: '[Yo Buddy] - Key Period Expired'
    end
end
