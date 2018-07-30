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

    def activate_key
    end
end
