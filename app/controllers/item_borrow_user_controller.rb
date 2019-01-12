require 'securerandom'

class ItemBorrowUserController < ApplicationController

    include ItemBorrowUserHelper
    include ApplicationHelper

    before_action :check_token, except: [:follow_ups, :send_follow_up, :load_follow_ups_sent, :load_follow_ups_received]
    before_action :check_session, except: [:follow_ups, :send_follow_up, :load_follow_ups_sent, :load_follow_ups_received]
    before_action :set_item_data
    before_action :set_data_items_counts, only: [:index, :show]
    before_action :check_owner_borrow, only: [:show, :edit, :update, :update_status, :destroy, :borrow_review]
    before_action :check_active, except: [:follow_ups, :send_follow_up, :load_follow_ups_sent, :load_follow_ups_received]
    before_action :check_privacy, only: [:follow_ups, :send_follow_up, :load_follow_ups_sent, :load_follow_ups_received]
    skip_before_action :verify_authenticity_token, only: [:create, :update]

    def index
        @borrowers = @item.borrow_item_user.all.order(created_at: :desc)
        @favourites_count = @item.user.item_favourite.all.count
        @activate = "borrowed"
        @title = "YB - Borrows for #{@item.name}"
    end

    def show
        @borrow = @item.borrow_item_user.find(params[:id])
        @borrow_receiver = 0 
        if session[:user_id] == @borrow.user.id then
            @borrow_receiver = @borrow.item.user.id
        else 
            @borrow_receiver = @borrow.user.id
        end
        @time = Time.new
        @title = "YB - Borrow No #{@borrow.code}"
    end

    def description
        @borrow = @item.borrow_item_user.find(params[:id])
        render layout: false
    end

    def borrow_review
        @borrow = @item.borrow_item_user.find(params[:id])
        @reviews = @borrow.borrow_message.where("sender_id = 0 AND receiver_id = 0").order(created_at: :asc)
        @type = params[:type]
        if @type == "ajax" then render layout: false end
    end

    def download_borrow_data
        @time = Time.new
        @borrow = @item.borrow_item_user.find params[:id]
        
        borrower = "#{@borrow.code }-borrower-#{@borrow.user.username}-#{SecureRandom.hex(4)}"
        owner = "#{@borrow.code}-owner-#{@borrow.item.user.username}-#{SecureRandom.hex(4)}"
        
        @qr_borrower = RQRCode::QRCode.new(borrower)
        @qr_owner = RQRCode::QRCode.new(owner)

        @pdf = render_to_string pdf: "borrow_no_#{@borrow.code}.pdf", template: "item_borrow_user/download_borrow_data", encoding: "UTF-8"
        send_data @pdf, :filename => "borrow_no_#{@borrow.code}.pdf", :type => "application/pdf", :disposition => "attachment"
    end

    def new
        @type = params[:type]
        @borrow = BorrowItemUser.new
        @last_borrow = @item.borrow_item_user.last
        @title = "YB - New Borrow for #{@item.name}"
        if @type == "ajax" then render layout: false end
    end

    def create

        @borrow = BorrowItemUser.new(borrow_params)
        @borrow.user_id = session[:user_id]
        @borrow.status = @status[0]
        @borrow.last_update_user_id = session[:user_id]
        @borrow.uuid = generate_uuid("", 24)
        @borrow.admin_id = !@item.user.is_private? ? 1 : 1 #changes required

        from_date = check_from_date(params[:item_borrow])

        if @active == true then

            if from_date == 2 then
                render json: {"type" => "error", "text" => "Time Already Passed !!!"}
            elsif from_date == 1 then
                render json: {"type" => "error", "text" => "Date Should not be Less Than Tomorrow !!!"}
            else
                to_date = set_time_end(params[:item_borrow], from_date)
                quant = params[:item_borrow][:count].to_i
                rests = @item.count - check_counts(from_date, to_date)
                
                if rests < 0 then
                    rests = 0
                end

                if rests >= quant and @item.count >= quant then
                    @borrow.from_date = from_date
                    @borrow.to_date = to_date

                    item = Item.find(params[:item_borrow][:item_id])
                    if item.user.id != session[:user_id] then
                        if @borrow.save then
                            save_message("new", @borrow)
                            Notification.create([{user_from_id: session[:user_id], user_to_id: item.user.id, ressource: "item_borrow", ressource_id: @borrow.id, is_read: false}])
                            BorrowUserMailer.with(borrow: @borrow).create.deliver_now
                            render json: {"type" => "success", "text" => "Item Borrow Request Sent !!!", "url" => item_borrow_url(@borrow.uuid, @borrow.item, @borrow)}
                        else
                            render json: {"type" => "error", "text" => @borrow.errors}
                        end
                    else
                         render json: {"type" => "error", "text" => "Cant Borrow Your Own Item !!!"}
                    end
                else
                    render json: {"type" => "info", "text" => "Available Items On That Date is #{rests}"}
                end
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def edit
        @item_borrow = @item.borrow_item_user.find(params[:id])
        @borrow_receiver = 0 
        if session[:user_id] == @item_borrow.user.id then
            @borrow_receiver = @item_borrow.item.user.id
        else 
            @borrow_receiver = @item_borrow.user.id
        end
        @title = "YB - Edit Borrow No #{@item_borrow.code}"
        render layout: false
    end

    def update
        respond_to do |format|

            @borrow = @item.borrow_item_user.find(params[:id])
            data = params[:item_borrow]

            from_date = check_from_date(params[:item_borrow])

            if @active == true then 

                if from_date == 2 then
                    flash[:danger] = "Time Already Passed !!!"
                    format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                    format.json{render json: {"type" => "error", "text" => "Time Already Passed !!!"}}
                elsif from_date == 1 then
                    flash[:danger] = "Date Should not be Less Than Tomorrow !!!"
                    format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                    format.json{render json: {"type" => "error", "text" => "Date Should not be Less Than Tomorrow !!!"}}
                else
                    to_date = set_time_end(params[:item_borrow], from_date)
                    quant = params[:item_borrow][:count].to_i
                    rests = @item.count - check_counts(from_date, to_date)

                    if rests < 0 then
                        rests = 0
                    end

                    if rests >= quant and @item.count >= quant then
                        @borrow.from_date = from_date
                        @borrow.to_date = to_date

                        if Array[@status[0], @status[2]].include?(@borrow.status)
                            if @borrow.update(update_params) then
                                save_message("data", @borrow)
                                Notification.create([{user_from_id: session[:user_id], user_to_id: (@borrow.user.id == session[:user_id]) ? @borrow.item.user.id : @borrow.user.id , ressource: "update_borrow_content", ressource_id: @borrow.id, is_read: false}])
                                BorrowUserMailer.with(borrow: @borrow).update((@borrow.user.id == session[:user_id]) ? @borrow.item.user.email : @borrow.user.email).deliver_now
                                flash[:success] = "Borrow Item Updated !!!"
                                format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                                format.json{render json: {"type" => "success", "text" => "Borrow Item Updated !!!"}}
                            else
                                flash[:danger] = @borrow.errors.full_messages
                                format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                                format.json{render json: {"type" => "error", "text" => @borrow.errors.full_messages}}
                            end
                        else
                            flash[:danger] = "Cant Update For Status : #{@borrow.status.capitalize} !!!"
                            format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                            format.json{render json: {"type" => "error", "text" => "Cant Update For Status : #{@borrow.status.capitalize} !!!"}}
                        end
                    else
                        flash[:danger] = "Available Items On That Date is #{rests}"
                        format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                        format.json{render json: {"type" => "error", "text" => "Available Items On That Date is #{rests}"}}
                    end
                end
            else
                flash[:danger] = "Your Private Account Is Not Active !!!"
                format.html{redirect_to item_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)}
                format.json{render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}}
            end
        end
    end

    def update_status
        status = params[:status]
        borrow = @item.borrow_item_user.find(params[:id])
        if @active == true and borrow.last_update_user_id != session[:user_id] then
            if status != nil and Array[0,1,2].include?(status.to_i) then
                if status.to_i == 1 then
                    if  Array[@status[0], @status[2]].include?(borrow.status) then
                        rests = @item.count - check_counts(borrow.from_date, borrow.to_date)

                        if rests < 0 then
                            rests = 0
                        end

                        if rests >= borrow.count.to_i then
                            save_message(@status[status.to_i], borrow)
                            Notification.create([{user_from_id: session[:user_id], user_to_id: (borrow.user.id == session[:user_id]) ? borrow.item.user.id : borrow.user.id , ressource: "update_borrow_#{@status[status.to_i]}", ressource_id: borrow.id, is_read: false}])
                            BorrowUserMailer.with(borrow: borrow).status((borrow.user.id == session[:user_id]) ? borrow.item.user.email : borrow.user.email).deliver_now
                            render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}
                        else
                            render json: {"type" => "info", "text" => "Cant Accept This Borrow, Available On That Date is #{rests}"}
                        end
                    else
                        render json: {"type" => "error", "text" => "Wrong Status !!!"}
                    end
                elsif status.to_i == 2 then
                    if borrow.status  == @status[0] then
                        save_message(@status[status.to_i], borrow)
                        Notification.create([{user_from_id: session[:user_id], user_to_id: (borrow.user.id == session[:user_id]) ? borrow.item.user.id : borrow.user.id , ressource: "update_borrow_#{@status[status.to_i]}", ressource_id: borrow.id, is_read: false}])
                        BorrowUserMailer.with(borrow: borrow).status((borrow.user.id == session[:user_id]) ? borrow.item.user.email : borrow.user.email).deliver_now
                        render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}
                    else
                        render json: {"type" => "error", "text" => "Wrong Status !!!"}
                    end
                else
                    if @status.slice(3, @status.length).push("accepted").include?(borrow.status) then
                        save_message(@status[status.to_i], borrow)
                        Notification.create([{user_from_id: session[:user_id], user_to_id: (borrow.user.id == session[:user_id]) ? borrow.item.user.id : borrow.user.id , ressource: "update_borrow_#{@status[status.to_i]}", ressource_id: borrow.id, is_read: false}])
                        BorrowUserMailer.with(borrow: borrow).status((borrow.user.id == session[:user_id]) ? borrow.item.user.email : borrow.user.email).deliver_now
                        render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}
                    else
                        render json: {"type" => "error", "text" => "Wrong Status !!!"}
                    end
                end   
            else
                render json: {"type" => "error", "text" => "Unknown Status !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def destroy
        borrow = BorrowItemUser.find(params[:id])
        respond_to do |format|
            if @active == true then
                if borrow.user.id == session[:user_id] or borrow.item.user.id == session[:user_id] then
                    if borrow.status == @status[6] then
                        borrow.is_deleted = true
                        borrow.save
                        flash[:success] = "Item Borrow Deleted !!!"
                        format.html{ redirect_to session_borrow_path }
                        format.json{ render json: {"type" => "success", "text" => "Item Borrow Deleted !!!"} }
                    else
                        flash[:danger] = "Cant Delete Borrow !!!"
                        format.html{ redirect_to session_borrow_path }
                        format.json{ render json: {"type" => "error", "text" => "Cant Delete Borrow !!!"} }
                    end
                else
                    flash[:danger] = "You are not the Owner !!!"
                    format.html{ redirect_to session_borrow_path }
                    format.json{ render json: {"type" => "error", "text" => "You are not the Owner !!!"} }
                end
            else
                flash[:danger] = "Your Private Account Is Not Active !!!"
                format.html{ redirect_to session_borrow_path }
                format.json{ render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"} }
            end
        end
    end

    def extend
        @item_borrow = @item.borrow_item_user.find(params[:id])
        @type = "ajax"
        render layout: false
    end

    def extend_borrow
        @borrow = @item.borrow_item_user.find(params[:id])
        from_date = check_from_date({from_date: @borrow.to_date.to_s})
        if session[:user_id] == @borrow.user.id and @borrow.was_rendered then
            if @borrow.per != ApplicationHelper::PERS[0] and (@borrow.to_date.localtime.to_i - 36 * 60 * 60) > Time.now.localtime.to_i then
                to_date = set_time_end(params[:item_borrow], from_date)
                rests = @item.count - check_counts(from_date, to_date)

                if rests >= @borrow.numbers then
                    @borrow.extension = params[:item_borrow][:numbers]
                    @borrow.save
                    message = @borrow.borrow_message.where(message: "extension_request_sent").last
                    if message != nil then
                        message.destroy
                    end
                    BorrowMessage.create([{borrow_item_user_id: @borrow.id, sender_id: 0, receiver_id: 0, message: "extension_request_sent", status: "unread", has_images: false, is_deleted: false}])
                    Notification.create([{user_from_id: @borrow.user.id, user_to_id: @borrow.item.user.id, ressource: "extend_borrow_request_#{@borrow.extension}", ressource_id: @borrow.id, is_read: false}])
                    BorrowUserMailer.with(borrow: @borrow).extend_borrow(@borrow.item.user.email).deliver_now
                    render json: {"type" => "success", "text" => "Borrow Extension Request Sent !!!"}
                else
                    render json: {"type" => "error", "text" => "Not Enough Items to borrow to the end date !!!"}
                end
            else
                render json: {"type" => "error", "text" => "The Extend Request must be sent 36 hours before the end of the borrow !!!"}
            end
        else
            render json: {"type" => "error", "text" => "You're not the Borrower !!!"}
        end
    end

    def update_borrow_extension_status
        @borrow = @item.borrow_item_user.find(params[:id])
        from_date = check_from_date({from_date: @borrow.to_date.to_s})
        if session[:user_id] == @borrow.item.user.id and @borrow.was_rendered then
            if @borrow.per != ApplicationHelper::PERS[0] and (@borrow.to_date.localtime.to_i - 24 * 60 * 60) > Time.now.localtime.to_i then
                if params[:status] == "accept" then
                    to_date = set_time_end(params[:item_borrow], from_date)
                    rests = @item.count - check_counts(from_date, to_date)

                    if rests >= @borrow.numbers then
                        @borrow.numbers += @borrow.extension
                        @borrow.to_date = to_date
                        @borrow.save
                        save_message_extension_status_update "accepted"
                        render json: {"type" => "success", "text" => "Borrow Extension Request Accepted !!!"}
                    else
                        save_message_extension_status_update "canceled"
                        render json: {"type" => "error", "text" => "Not Enough Items to borrow to the end date !!!"}
                    end
                else
                    save_message_extension_status_update "rejected"
                    render json: {"type" => "success", "text" => "Borrow Extension Request Rejected !!!"}
                end
            else
                save_message_extension_status_update "canceled"
                render json: {"type" => "error", "text" => "The Extend Request must be sent 24 hours before the end of the borrow !!!"}
            end
        else
            render json: {"type" => "error", "text" => "You're not the Lender !!!"}
        end

    end

    def renew
        @item_borrow = @item.borrow_item_user.find(params[:id])
        @type = "ajax"
        render layout: false
    end

    def renew_borrow
    end

    def follow_ups
        @sender = session[:admin] != nil ? 0 : @borrow.user.id
        @receiver = session[:admin] != nil ? @borrow.user.id : 0 
        @with = session[:admin] != nil ? @borrow.user.username.capitalize! : "Yo Buddy" 
        render layout: false
    end

    def send_follow_up
        @borrow.borrow_item_follow_up.create({admin_id: @borrow.admin.id, about: "follow_up", message: params[:follow_up][:message]});
        render json:{"type" => "success", "text" => params[:follow_up][:message]}
    end

    def load_follow_ups_sent
        @messages =  @borrow.borrow_item_follow_up.all.order(created_at: :asc)
        render layout: false
    end

    def load_follow_ups_received
        @messages =  @borrow.follow_ups_admin
        render layout: false
    end

    private def borrow_params
        params.require(:item_borrow).permit(:item_id, :price, :currency, :per, :numbers, :conditions, :count, :reasons)
    end

    private def update_params
        params.require(:item_borrow).permit(:item_id, :price, :currency, :per, :numbers, :conditions, :status, :last_update_user_id)
    end

    private def check_privacy
        @item = Item.find(params[:item_id]) if params[:item_id] != nil
        @borrow = @item.borrow_item_user.find(params[:item_borrow_user_id])
        if session[:admin] == nil then
            if @borrow.item.user.is_private? or @borrow.item.user.id != session[:user_id] then
                render json: {"type" => "error", "text" => "unauthorized"}
            end
        else
            admin =  Admin.find(session[:admin])
            if @borrow.admin.id != admin.id then
                if admin.privileges != "all" then
                    render json: {"type" => "error", "text" => "unauthorized"}
                end
            end
        end
    end

    private def save_message_extension_status_update(status)
        message = @borrow.borrow_message.where(message: "extension_request_sent").last
        if message != nil then
            message.destroy
        end
        BorrowMessage.create([{borrow_item_user_id: @borrow.id, sender_id: 0, receiver_id: 0, message: "extension_request_#{status}_#{@borrow.extension}", status: "unread", has_images: false, is_deleted: false}])
        @borrow.extension = 0
        @borrow.save
        Notification.create([{user_from_id: @borrow.item.user.id, user_to_id: @borrow.user.id, ressource: "extend_borrow_request_status_#{status}", ressource_id: @borrow.id, is_read: false}])
    end
end