class BorrowUserMailer < ApplicationMailer
	
    def create
  		  @borrow = params[:borrow]
        mail(to: @borrow.item.user.email, subject: '[Yo Buddy] - New Request For Borrow Item')
  	end

  	def update(email)
        @borrow = params[:borrow]
        mail(to: email, subject: '[Yo Buddy] - Borrow Item Content Update')
  	end

  	def status(email)
        @borrow = params[:borrow]
        mail(to: email, subject: '[Yo Buddy] - Borrow Item Status Update')
  	end

  	def failed(email)
        @borrow = params[:borrow]
        mail(to: email, subject: '[Yo Buddy] - Borrow Item Failed')
  	end

    def update_required(email)
        @borrow = params[:borrow]
        mail(to: email, subject: '[Yo Buddy] - Request To Update Borrow Item')
    end

end
