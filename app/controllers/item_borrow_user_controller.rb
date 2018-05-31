class ItemBorrowUserController < ApplicationController

    include ItemBorrowUserHelper

    before_action :check_session
    before_action :set_item_data
    before_action :set_data_items_counts, only: [:index, :show]
    before_action :check_borrows
    before_action :check_owner_borrow, only: [:show, :edit, :update, :update_status, :destroy]

    def index
        @borrowers = @item.borrow_item_user.all.order(created_at: :desc)
        @favourites_count = @item.user.item_favourite.all.count
        @activate = "borrowed"
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
    end

    def new
        @borrow = BorrowItemUser.new
        @last_borrow = @item.borrow_item_user.last
        render layout: false
    end

    def create

        @borrow = BorrowItemUser.new(borrow_params)
        @borrow.user_id = session[:user_id]
        @borrow.status = @status[0]
        @borrow.last_update_user_id = session[:user_id]

        from_date = check_from_date(params[:item_borrow])

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
                        render json: {"type" => "success", "text" => "Item Borrow Request Sent !!!"}
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
    end

    def edit
        @item_borrow = @item.borrow_item_user.find(params[:id])
        render layout: false
    end

    def update
        respond_to do |format|

            @borrow = @item.borrow_item_user.find(params[:id])
            data = params[:item_borrow]

            from_date = check_from_date(params[:item_borrow])


            if from_date == 2 then
                flash[:danger] = "Time Already Passed !!!"
                format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
                format.json{render json: {"type" => "error", "text" => "Time Already Passed !!!"}}
            elsif from_date == 1 then
                flash[:danger] = "Date Should not be Less Than Tomorrow !!!"
                format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
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
                            flash[:success] = "Borrow Item Updated !!!"
                            format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
                            format.json{render json: {"type" => "success", "text" => "Borrow Item Updated !!!"}}
                        else
                            flash[:danger] = @borrow.errors.full_messages
                            format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
                            format.json{render json: {"type" => "error", "text" => @borrow.errors.full_messages}}
                        end
                    else
                        flash[:danger] = "Cant Update For Status : #{@borrow.status.capitalize} !!!"
                        format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
                        format.json{render json: {"type" => "error", "text" => "Cant Update For Status : #{@borrow.status.capitalize} !!!"}}
                    end
                else
                    flash[:danger] = "Available Items On That Date is #{rests}"
                    format.html{redirect_to item_item_borrow_user_path(@item, @borrow)}
                    format.json{render json: {"type" => "error", "text" => "Available Items On That Date is #{rests}"}}
                end
            end
        end
    end

    def update_status
        status = params[:status]
        borrow = @item.borrow_item_user.find(params[:id])
        respond_to do |format|
            if status != nil and Array[0,1,2].include?(status.to_i) then
                if status.to_i == 1 then
                    if  Array[@status[0], @status[2]].include?(borrow.status) then
                        rests = @item.count - check_counts(borrow.from_date, borrow.to_date)

                        if rests < 0 then
                            rests = 0
                        end

                        if rests >= borrow.count.to_i then
                            borrow.status = @status[status.to_i]
                            borrow.save
                            save_message(@status[status.to_i], borrow)
                            format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                            format.json {render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}}
                            flash[:success] = "Borrow Request #{@status[status.to_i].capitalize} !!!"
                        else
                            format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                            format.json {render json: {"type" => "info", "text" => "Cant Accept This Borrow, Available On That Date is #{rests}"}}
                            flash[:info] = "Cant Accept This Borrow, Available On That Date is #{rests}"
                        end
                    else
                        format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                        format.json{ render json: {"type" => "error", "text" => "Wrong Status !!!"}}
                        flash[:danger] = "Wrong Status !!!"
                    end
                elsif status.to_i == 2 then
                    if borrow.status  == @status[0] then
                        borrow.status = @status[status.to_i]
                        borrow.save
                        save_message(@status[status.to_i], borrow)
                        format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                        format.json {render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}}
                        flash[:success] = "Borrow Request #{@status[status.to_i].capitalize} !!!"
                    else
                        format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                        format.json{ render json: {"type" => "error", "text" => "Wrong Status !!!"}}
                        flash[:danger] = "Wrong Status !!!"
                    end
                else
                    if @status.slice(3, @status.length).push("accepted").include?(borrow.status) then
                        borrow.status = @status[status.to_i]
                        borrow.save
                        save_message(@status[status.to_i], borrow)
                        format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                        format.json {render json: {"type" => "success", "text" => "Borrow Request #{@status[status.to_i].capitalize} !!!"}}
                        flash[:success] = "Borrow Request #{@status[status.to_i].capitalize} !!!"
                    else
                        format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                        format.json{ render json: {"type" => "error", "text" => "Wrong Status !!!"}}
                        flash[:danger] = "Wrong Status !!!"
                    end
                end
                
            else
                format.html{ redirect_to item_item_borrow_user_path(@item, borrow) }
                format.json{ render json: {"type" => "error", "text" => "Unknown Status !!!"}}
                flash[:danger] = "Unknown Status !!!";
            end
        end
    end

    def destroy
        borrow = BorrowItemUser.find(params[:id])
        respond_to do |format|
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
        end
    end

    private def borrow_params
        params.require(:item_borrow).permit(:item_id, :price, :currency, :per, :numbers, :conditions, :count)
    end

    private def update_params
        params.require(:item_borrow).permit(:item_id, :price, :currency, :per, :numbers, :conditions, :status, :last_update_user_id)
    end
end
