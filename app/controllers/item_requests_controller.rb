class ItemRequestsController < ApplicationController

    include ItemRequestsHelper
    include ItemBorrowUserHelper
    include ApplicationHelper

    before_action :check_session, only: [:new, :edit, :update, :create, :destroy, :like_item]
    before_action :set_item_data_item, only: [:new, :edit, :create, :update, :show, :suggestion_new, :suggestion_create, :suggestion_exist, :suggesion_create_exist, :suggestion_edit]
    before_action :set_item_request, only: [:show, :edit, :update, :destroy]
    before_action :set_request_helper
    before_action :check_active

    def index
        @requests = ItemRequest.where(status: @status[0]).order(to_date: :asc)
    end

    def show
        @request = ItemRequest.find(params[:id])
        @suggestions = @request.item_request_suggestion.where(status: @sug_status[1]).count
    end

    def like
        @like = ItemRequestLike.new
        @like.item_request_id = params[:like][:item_request_id]
        @like.user_id = session[:user_id]
        
        check_like = ItemRequestLike.where(user_id: session[:user_id], item_request_id: params[:like][:item_request_id]).first
        item_request = ItemRequest.find(params[:like][:item_request_id])

        if @active == true then
        
            if check_like == nil then
                if @like.save then
                    Notification.create([{user_from_id: session[:user_id], user_to_id: item_request.user.id, ressource: "item_request_like", ressource_id: item_request.id, is_read: false}])
                    render json: {"type" => "like", "text" => "Item Request Liked !!!"}
                else
                    render json: {"type" => "error", "error" => @like.errors.full_messages}
                end
            else
                check_like.destroy
                render json: {"type" => "dislike", "text" => "Item Request Disliked !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def new
        @request = ItemRequest.new
        render layout: false
    end

    def create
        @request = ItemRequest.new(item_request_params)
        @request.user_id = session[:user_id]
        @request.is_deleted = false
        @request.status = @status[0]
        @request.uuid = generate_uuid(params[:item_request][:title])
        from_date = check_from_date(params[:item_request])

        respond_to do |format|

            if @active == true then

                if from_date == 2 then
                    flash[:danger] = "Time Already Passed !!!"
                    format.html{ redirect_to session_requests_path }
                    format.json{render json: {"type" => "error", "text" => "Time Already Passed !!!"}}
                elsif from_date == 1 then
                    flash[:danger] = "Date Should not be Less Than Tomorrow !!!"
                    format.html{ redirect_to session_requests_path }
                    format.json{render json: {"type" => "error", "text" => "Date Should not be Less Than Tomorrow !!!"}}
                else
                    @request.from_date = from_date
                    @request.to_date = set_time_end(params[:item_request], from_date)
                    if @request.save then
                        images = params[:item_request][:images]
                        for image in images
                            @image = ItemRequestImage.new
                            @image.item_request_id = @request.id
                            @image.image = image
                            if @image.save then
                            else
                                flash[:danger] =  @image.errors.full_messages
                                format.json{ render json: {"type" => "error", "text" => @image.errors.full_messages} }
                            end
                        end
                        flash[:success] = "Item Request Added Successfully !!!"
                        format.html{ redirect_to session_requests_path }
                        format.json{ render json: {"type" => "success", "text" => "Item Request Added Successfully !!!"} }
                    else
                        flash[:danger] = @request.errors.full_messages
                        format.html{ redirect_to session_requests_path }
                        format.json{ render json: {"type" => "error", "text" => @request.errors.full_messages} }
                    end
                end
            else
                flash[:danger] = "Your Private Account Is Not Active !!!"
                format.html{ redirect_to session_requests_path }
                format.json{ render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"} }
            end
        end
    end

    def edit
        if is_logged_in?
            @request = ItemRequest.find(params[:id])
            if @request.user.id == session[:user_id] then
                render layout: false
            end
        end
    end

    def update
        @request = ItemRequest.find(params[:id])
        from_date = check_from_date(params[:item_request])
        respond_to do |format|

            if @active == true then
                if Array[@status[0], @status[2]].include?(@request.status) then
                    if @request.user.id == session[:user_id] then
                        if from_date == 2 then
                            render json: {"type" => "error", "text" => "Time Already Passed !!!"}
                        elsif from_date == 1 then
                            render json: {"type" => "error", "text" => "Date Should not be Less Than Tomorrow !!!"}
                        else
                            @request.from_date = from_date
                            @request.to_date = set_time_end(params[:item_request], from_date)
                            @request.status = @status[0]
                            subcat = Subcategory.find(params[:item_request][:subcategory_id])
                            if subcat.category.id == params[:item_request][:category_id].to_i then
                                if @request.update(item_request_params) then
                                    images = params[:item_request][:images]
                                    if images then
                                        for image in images
                                            @image = ItemRequestImage.new
                                            @image.item_request_id = @request.id
                                            @image.image = image
                                            if @image.save then
                                            else
                                                flash[:danger] =  @image.errors.full_messages
                                                format.json{ render json: {"type" => "error", "text" => @image.errors.full_messages} }
                                            end
                                        end
                                    end
                                    flash[:success] = "Item Request Updated Successfully !!!"
                                    format.html{ redirect_to item_request_path(@request) }
                                    format.json{ render json: {"type" => "success", "text" => "Item Request Added Successfully !!!"} }
                                else
                                    flash[:danger] = @request.errors.full_messages
                                    format.html{ redirect_to item_request_path(@request) }
                                    format.json{ render json: {"type" => "error", "text" => @request.errors.full_messages} }
                                end
                            else
                                flash[:danger] = "Subcategory not the child of category !!!"
                                format.html{ redirect_to item_request_path(@request) }
                                format.json{ render json: {"type" => "error", "text" => "Subcategory not the child of category !!!"} }
                            end
                        end
                    else
                        flash[:danger] = "You are not the owner !!!"
                        format.html{ redirect_to item_request_path(@request) }
                        format.json{ render json: {"type" => "error", "text" => "You are not the owner !!!"} }
                    end
                else
                    flash[:danger] = "Cant update for request status is #{@request.status} !!!"
                    format.html{ redirect_to item_request_path(@request) }
                    format.json{ render json: {"type" => "error", "text" => "Cant update for request status is #{@request.status} !!!"} }
                end
            else
                flash[:danger] = "Your Private Account Is Not Active !!!"
                format.html{ redirect_to item_request_path(@request) }
                format.json{ render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"} }
            end
        end
    end

    def update_request_status
        @request = ItemRequest.find(params[:id])
        status = params[:status].to_i
        if @active == true then
            if @request.user.id == session_user.id then
                if status < @status.length then
                    suggestions = @request.item_request_suggestion.where(status: @sug_status[1]).count
                    if suggestions > 0 and status == 2 then
                        flash[:danger] = "You Have Accepted Suggestions !!!"
                    else
                        @request.status = @status[status]
                        @request.save
                        flash[:success] = "Item Request Status Updated To #{@status[status].upcase} !!!"
                    end
                elsif status == 3 or status == 4 then
                    @request.status = @status[0]
                    @request.item_request_suggestion.each do |suggestion|
                        suggestion.status = @sug_status[3]
                        suggestion.save
                    end
                    flash[:success] = "Item Request Reset !!!"
                else
                    flash[:danger] = "Unknown Item Request Status !!!"
                end
            else
                flash[:danger] = "You are not the owner !!!"
            end
        else
            flash[:danger] = "Your Private Account Is Not Active !!!"
        end
        redirect_to item_request_path(@request)
    end

    def destroy
    end

    def delete_item_request_image
        @request = ItemRequest.find(params[:item_request_id])
        @image = @request.item_request_image.find(params[:id])
        @images = @request.item_request_image.all
        if @active == true then
            if @image.item_request.user.id == session[:user_id] then
                if @images.length > 2 then
                    @image.destroy
                    render json: {"type" => "success", "text" => "Image Deleted Successfully !!!"}
                else
                    render json: {"type" => "error", "text" => "Item Images Are Few !!!"}
                end
            else
                render json: {"type" => "error", "text" => "You are not the owner !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def suggestion_all
        @request = ItemRequest.find(params[:id])
        @suggestions = @request.item_request_suggestion.where("status != :status", {status: @sug_status[3]}).order(price: :asc)
        render layout: false
    end

    def suggestion_new
        @request = ItemRequest.find(params[:id])
        @suggestion = Item.new
        if !is_logged_in?
            flash[:danger] = "Loggin Required !!!"
            redirect_to new_user_path + "?layout=false&url=#{item_request_path(@request)}"
        else
            render layout: false
        end
    end

    def suggestion_create
        @request = ItemRequest.find(params[:id])
        if @active == true then
            if @request.status == @status[0] then
                if @request.user.id != session[:user_id] then
                    @item = Item.new(item_request_suggestion_params)
                    @item.user_id = session[:user_id]
                    @item.is_available = false
                    @item.is_deleted = false

                    can_add = can_add_item(session[:user_id], params[:item][:count].to_i)

                    if !can_add? then
                        render json: {"type" => "error", "text" => "Your Private Account Is Not Active or Items Exceed The Subscribed Package !!!"}
                    end

                    if @item.save then
                        images = params[:item][:image]
                        for image in images
                            @image = ItemImage.new
                            @image.item_id = @item.id
                            @image.image = image
                            @image.save 
                        end
                        @suggestion = ItemRequestSuggestion.new
                        @suggestion.item_request_id = @request.id
                        @suggestion.item_id = @item.id
                        @suggestion.price = @item.price
                        @suggestion.currency = @item.currency
                        @suggestion.per = @item.per
                        @suggestion.status = @sug_status[0]
                        if @suggestion.save then
                            Notification.create([{user_from_id: session[:user_id], user_to_id: @request.user.id , ressource: "item_request_suggest", ressource_id: @request.id, is_read: false}])
                            render json: {"type" => "success", "text" => "Item Request Suggestion Added Successfully !!!"}
                        else
                            render json: {"type" => "error", "text" => @suggestion.errors.full_messages}
                        end
                    else
                        render json: {"type" => "error", "text" => @item.errors.full_messages}
                    end
                else
                    render json: {"type" => "error", "text" => "Cant suggest to your own Request !!!"}
                end
            else
                render json: {"type" => "error", "text" => "This request is Finnished !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def suggestion_exist
        @request = ItemRequest.find(params[:id])
        if !is_logged_in?
            flash[:danger] = "Loggin Required !!!"
            redirect_to new_user_path + "?layout=false&url=#{item_request_path(@request)}"
        else
            @items = session_user.item.where(category_id: @request.category.id).order(name: :asc)
            render layout: false
        end
    end

    def suggesion_create_exist
        @request = ItemRequest.find(params[:id])
        item = params[:suggestion][:item_id]
        if @active == true then
            if @request.status == @status[0] then
                if @request.user.id != session[:user_id] then
                    if item != "0" then
                        check_suggestion = @request.item_request_suggestion.where("item_id = :item AND (status = :status OR status = :status_else)", {item: item, status: @sug_status[0], status_else: @sug_status[1]})
                        if check_suggestion == nil or check_suggestion.empty? then
                            @item = Item.find(item)
                            rests = @item.count - check_counts(@request.from_date, @request.to_date)
                            if rests > 0 then
                                @suggestion = ItemRequestSuggestion.new(params[:suggestion].permit(:item_id, :price, :currency, :per))
                                @suggestion.item_request_id = @request.id
                                @suggestion.status = @sug_status[0]
                                if @suggestion.save then
                                    Notification.create([{user_from_id: session[:user_id], user_to_id: @request.user.id , ressource: "item_request_suggest", ressource_id: @request.id, is_read: false}])
                                    render json: {"type" => "success", "text" => "Item Request Suggestion Added Successfully !!!"}
                                else
                                    render json: {"type" => "error", "text" => @suggestion.errors.full_messages}
                                end
                            else
                                render json: {"type" => "error", "text" => "Item To borrow in durring the date is less than 1 !!!"}
                            end
                        else
                            render json: {"type" => "error", "text" => "Item is Already Suggested !!!"} 
                        end
                    else
                        render json: {"type" => "error", "text" => "Please, Select an Item !!!"}
                    end
                else
                    render json: {"type" => "error", "text" => "Cant suggest to your own Request !!!"}
                end
            else
                render json: {"type" => "error", "text" => "This request is Finnished !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def suggestion_edit
        @request = ItemRequest.find(params[:item_request_id])
        @suggestion = @request.item_request_suggestion.find(params[:id])
        if session_user.id == @suggestion.item.user.id then
            render layout: false
        else
            flash[:danger] = "You are not the owner !!!"
            redirect_to new_user_path + "?layout=false"
        end
    end

    def suggestion_update
        @request = ItemRequest.find(params[:item_request_id])
        @suggestion = @request.item_request_suggestion.find(params[:id])
        if @active == true then
            if session_user.id == @suggestion.item.user.id then
                if @suggestion.update(params[:item_request_suggestion].permit(:price, :currency, :per, :status)) then
                    Notification.create([{user_from_id: session[:user_id], user_to_id: @request.user.id , ressource: "update_item_request_suggest_content", ressource_id: @request.id, is_read: false}])
                    render json: {"type" => "success", "text" => "Item Request Updated Successfully !!!"}
                else
                    render json: {"type" => "error", "text" => @suggestion.errors.full_messages}
                end
            else
                render json: {"type" => "error", "text" => "You are not the owner !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def suggestion_update_status
        @request = ItemRequest.find(params[:item_request_id])
        @suggestion = @request.item_request_suggestion.find(params[:id])
        @item = Item.find(@suggestion.item.id)
        rests = @item.count - check_counts(@request.from_date, @request.to_date)
        status = params[:status].to_i
        type = params[:type]
        if @active == true then
            if @request.status == @status[0] then
                if session_user.id == @request.user.id then
                    if status == 1 then
                        if rests > 0 then
                            if rests >= @request.count then
                                @suggestion.status = @sug_status[status]
                                @suggestion.save
                                accept_suggestion(@suggestion, @request.count)
                                Notification.create([{user_from_id: session[:user_id], user_to_id: @suggestion.item.user.id , ressource: "update_item_request_suggest_#{@sug_status[status]}", ressource_id: @request.id, is_read: false}])
                                render json: {"type" => "success", "text" => "Item Suggestion Status Updated To #{@sug_status[status].capitalize} !!!", "borrow" => "Item Borrow User Request Sent !!!"}
                            else
                                if type == "check" then
                                    render json: {"type" => "check", "text" => rests}
                                elsif type == "update" then
                                    @suggestion.status = @sug_status[status]
                                    @suggestion.save
                                    accept_suggestion(@suggestion, rests)
                                    Notification.create([{user_from_id: session[:user_id], user_to_id: @suggestion.item.user.id , ressource: "update_item_request_suggest_#{@sug_status[status]}", ressource_id: @request.id, is_read: false}])
                                    render json: {"type" => "success", "text" => "Item Suggestion Status Updated To #{@sug_status[status].capitalize} !!!"}
                                else
                                    render json: {"type" => "error", "text" => "Unknown Update Type !!!"}
                                end
                            end
                        else
                            render json: {"type" => "error", "text" => "No Item Available To Borrow !!!"}
                        end
                    else
                        @suggestion.status = @sug_status[status]
                        @suggestion.save
                        render json: {"type" => "success", "text" => "Item Suggestion Status Updated To #{@sug_status[status].capitalize} !!!"}
                    end
                else
                    render json: {"type" => "error", "text" => "You are not the owner !!!"}
                end
            else
                render json: {"type" => "error", "text" => "This request is Finnished !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    private def set_item_request
        @request = ItemRequest.find(params[:id])
    end

    private def item_request_params
        params[:item_request].permit(:title, :category_id, :subcategory_id, :min_price, :max_price, :currency, :per, :numbers, :description, :count)
    end

    private def item_request_suggestion_params
        params.require(:item).permit(:name, :category_id, :subcategory_id, :price, :currency, :per, :description, :count, :is_temp)
    end

    private def accept_suggestion(suggestion, quantity)
        borrow = BorrowItemUser.new
        borrow.item_id = suggestion.item.id
        borrow.user_id = suggestion.item_request.user.id
        borrow.price = suggestion.price
        borrow.currency = suggestion.currency
        borrow.per = suggestion.per
        borrow.numbers = suggestion.item_request.numbers
        borrow.count = quantity
        borrow.conditions = suggestion.item_request.description
        borrow.from_date = suggestion.item_request.from_date
        borrow.to_date = suggestion.item_request.to_date
        borrow.last_update_user_id = suggestion.item.user.id #suggestion.item_request.user.id
        borrow.status = "pending"
        borrow.save
        save_message("new", borrow)
    end
end
