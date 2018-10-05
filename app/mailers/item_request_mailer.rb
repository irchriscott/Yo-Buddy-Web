class ItemRequestMailer < ApplicationMailer

    def suggest
        @suggestion = params[:suggestion]
        @request = params[:request]

        mail(to: @request.user.email, subject: '[Yo Buddy] - New Suggestion To Your Item Request')
    end

    def update_suggestion
        @suggestion = params[:suggestion]
        @request = params[:request]

        mail(to: @request.user.email, subject: '[Yo Buddy] - Suggestion Upddated')
    end

    def update_suggestion_status
        @suggestion = params[:suggestion]
        @request = params[:request]

        mail(to: @suggestion.item.user.email, subject: '[Yo Buddy] - Suggestion Status Upddated')
    end

    def update_request
        @suggestion = params[:suggestion]
        @request = params[:request]

        mail(to: @suggestion.item.user.email, subject: '[Yo Buddy] - Item Request Content Updated')
    end
end
