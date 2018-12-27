class ItemsController < ApplicationController

    include ItemsHelper
    include ApplicationHelper

    before_action :check_session, only: [:new, :edit]
    before_action :set_item_data_item, only: [:new, :edit, :create, :update, :show]
    before_action :check_token, only:[:like_item, :like_item_destroy, :create, :destroy, :update, :delete_image_item, :favourite_item]
    skip_before_action :verify_authenticity_token, only: [:like_item, :like_item_destroy, :create, :destroy, :update, :delete_image_item, :favourite_item]
    before_action :check_active

    def index
        @items = Item.all.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    end

    def show
        @item = Item.find(params[:id])
    end

    def show_ajax
        @item = Item.find(params[:id])
        @others = Item.where("id != :id", {id: @item.id}).where(category_id: @item.category.id).limit(10).shuffle
        render layout: false
    end

    def new
        @source = params[:source]
        @type = params[:type]
        @item = Item.new
        if @type == "ajax" then render layout: false end
    end

    def create
        respond_to do |format|

            @item = Item.new(item_params)
            @item.user_id = (is_logged_in?) ? session[:user_id] : params[:item][:user_id]
            @item.is_available = true
            @item.is_deleted = false
            @item.uuid = generate_uuid(params[:item][:name])

            if @active == true then

                if can_add_item(session[:user_id], params[:item][:count].to_i) == false then
                    params[:source] == "admin" ? format.html { redirect_to admin_u_items_path } : format.html { redirect_to session_items_path }
                    format.json { render json: {"type" => "error", "text" => "Your Private Account Is Not Active or Items Exceed The Subscribed Package !!!"}, status: :unprocessable_entity }
                    flash[:danger] = "Your Private Account Is Not Active or Items Exceed The Subscribed Package !!!"
                end

                if @item.save then
                    images = params[:item][:image]
                    if images.count > 0 then
	                    for image in images
	                        @image = ItemImage.new
	                        @image.item_id = @item.id
	                        @image.image = image
	                        if @image.save then
	                        else
	                            flash[:danger] = @image.errors.full_messages
	                            format.json{ render json: {"type" => "error", "text" => @image.errors.full_messages} }
	                        end
	                    end
	                else
	                	@item.destroy
	                	params[:source] == "admin" ? format.html { redirect_to admin_u_items_path } : format.html { redirect_to session_items_path }
	                    format.json { render json: {"type" => "error", "text" => "Images cannot be null !!!"}, status: :unprocessable_entity }
	                    flash[:danger] = "Images cannot be null !!!"
	                end

                    if session_user.is_private? then
                        AdminItem.create([item_id: @item.id, borrow_id: 0, status: "Returned", is_available: true])
                    end

                    params[:source] == "admin" ? format.html { redirect_to admin_u_items_path } : format.html { redirect_to session_items_path }
                    format.json { render json: {"type" => "success", "text" => "Item Added Successfully !!!"} }
                    flash[:success] = "Item Added Successfully !!!"
                else
                    params[:source] == "admin" ? format.html { redirect_to admin_u_items_path } : format.html { redirect_to session_items_path }
                    format.json { render json: {"type" => "error", "text" => @item.errors.full_messages.to_s}, status: :unprocessable_entity }
                    flash[:danger] = @item.errors.full_messages
                end
            else
                params[:source] == "admin" ? format.html { redirect_to admin_u_items_path } : format.html { redirect_to session_items_path }
                format.json { render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}, status: :unprocessable_entity }
                flash[:danger] = "Your Private Account Is Not Active !!!"
            end
        end

    end

    def edit
        @item = Item.find(params[:id])
        @source = params[:source]
        if @item.user.id == session[:user_id] then
            render layout: false
        end
    end

    def update
        respond_to do |format|
            @item = Item.find(params[:id])
            @item.is_available = params[:item][:is_available]
            @item.uuid = generate_uuid(params[:item][:name])

            if @active == true then

                if @item.user.id == session[:user_id] then
                    subcat = Subcategory.find(params[:item][:subcategory_id])
                    if subcat.category.id == params[:item][:category_id].to_i then
                        if @item.update(item_params) then
                            images = params[:item][:image]
                            if images then
                                for image in images
                                    @image = ItemImage.new
                                    @image.item_id = @item.id
                                    @image.image = image
                                    if @image.save then
                                    else
                                        flash[:danger] = @image.errors.full_messages
                                    end
                                end
                            end
                            params[:source] == "admin" ? format.html { redirect_to admin_u_item_path(@item.user.username, @item.uuid, @item) } : format.html { redirect_to item_show_path(@item.user.username, @item.uuid, @item)  }
                            format.json { render json: {"type" => "success", "text" => "Item Updated Successfully !!!"} }
                            flash[:success] = "Item Updated Successfully !!!"
                        else
                            params[:source] == "admin" ? format.html { redirect_to admin_u_item_path(@item.user.username, @item.uuid, @item) } : format.html { redirect_to item_show_path(@item.user.username, @item.uuid, @item)  }
                            format.json { render json: { "type" => "error", "text" => @item.errors.full_messages.to_s }, status: :unprocessable_entity }
                            flash[:danger] = @item.errors.full_messages
                        end
                    else
                        params[:source] == "admin" ? format.html { redirect_to admin_u_item_path(@item.user.username, @item.uuid, @item) } : format.html { redirect_to item_show_path(@item.user.username, @item.uuid, @item)  }
                        format.json { render json: { "type" => "error", "text" => "Subcategory is not the child of Category !!!" }, status: :unprocessable_entity }
                        flash[:danger] = "Subcategory is not the child of Category !!!"
                    end
                else
                    params[:source] == "admin" ? format.html { redirect_to admin_u_item_path(@item.user.username, @item.uuid, @item) } : format.html { redirect_to item_show_path(@item.user.username, @item.uuid, @item)  }
                    format.json { render json: { "type" => "error", "text" => "You are not the owner !!!" }, status: :unprocessable_entity }
                    flash[:danger] = "You are not the owner !!!"
                end
            else
                params[:source] == "admin" ? format.html { redirect_to admin_u_item_path(@item.user.username, @item.uuid, @item) } : format.html { redirect_to item_show_path(@item.user.username, @item.uuid, @item)  }
                format.json { render json: { "type" => "error", "text" => "Your Private Account Is Not Active !!!" }, status: :unprocessable_entity }
                flash[:danger] = "Your Private Account Is Not Active !!!"
            end
        end
    end

    def available
        @dates = Array.new
        @item = Item.find(params[:id])
        now = Time.new.localtime
        @borrows = @item.borrow_item_user.where("status = :status OR status = :status_else", {status: "accepted", status_else: "rendered"}).order(from_date: :asc)
        
        if @borrows.count > 0 then
            if @borrows[0].from_date.localtime > now then
                date = Hash.new 
                date["from"] = now
                date["to"] = @borrows[0].from_date.localtime - (1 * 60 * 60)
                date["count"] = @item.count
                @dates.append(date)
            end
        else
            date = Hash.new 
            date["from"] = now
            date["to"] = "-"
            date["count"] = @item.count
            @dates.append(date)
        end


        @borrows.each_with_index do |_,i|
            if i != 0  then
                if @borrows[i - 1].from_date.localtime >= @borrows[i].from_date.localtime and @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                    @dates.append(date)
                end
                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].from_date.localtime  then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - @borrows[i - 1].count 
                    @dates.append(date)
                end
                
                if @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime and @borrows[i].from_date.localtime <= @borrows[i - 1].to_date.localtime then 
                    date = Hash.new 
                    date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                    @dates.append(date)
                    _date = Hash.new 
                    _date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    _date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                    _date["count"] = @item.count - @borrows[i].count.to_i 
                    @dates.append(_date)
                end

                if @borrows[i].from_date.localtime >= @borrows[i - 1].to_date.localtime and @borrows[i].to_date.localtime >= @borrows[i - 1].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    date["to"] = @borrows[i].from_date.localtime + (1 * 60 * 60)
                    date["count"] = @item.count
                    @dates.append(date)
                end

                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].to_date.localtime then
                    if @borrows[i].from_date.localtime > @borrows[i - 1].from_date.localtime then
                        date = Hash.new 
                        date["from"] = @borrows[i - 1].from_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i].from_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - @borrows[i - 1].count.to_i
                        @dates.append(date)
                    end

                    if true then
                        date = Hash.new 
                        date["from"] = @borrows[i].from_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i].to_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - (@borrows[i].count.to_i + @borrows[i - 1].count.to_i)
                        @dates.append(date)
                    end

                    if @borrows[i - 1].to_date.localtime > @borrows[i].to_date.localtime then
                        date = Hash.new 
                        date["from"] = @borrows[i].to_date.localtime - (1 * 60 * 60)
                        date["to"] = @borrows[i - 1].to_date.localtime + (1 * 60 * 60)
                        date["count"] = @item.count - @borrows[i - 1].count.to_i
                        @dates.append(date)
                    end
                end
            end
            if i == @borrows.count - 1 then
                if @borrows[i].from_date.localtime >= @borrows[i - 1].from_date.localtime and @borrows[i - 1].to_date.localtime >= @borrows[i].to_date.localtime then
                    date = Hash.new 
                    date["from"] = @borrows[i - 1].to_date.localtime - (1 * 60 * 60)
                    date["to"] = "-"
                    date["count"] = @item.count
                    @dates.append(date)
                else
                    date = Hash.new 
                    date["from"] = @borrows[i].to_date.localtime - (1 * 60 * 60)
                    date["to"] = "-"
                    date["count"] = @item.count
                    @dates.append(date)
                end
            end
        end

        render layout: false
    end

    def delete_image_item
        respond_to do |format|
            @image = ItemImage.find(params[:id])
            @item = Item.find(@image.item.id)
            @images = @item.item_image.all

            if @active == true then

                if @image.item.user.id == session[:user_id] then
                    if @images.length > 2 then
                        @image.destroy
                        format.html { render json: {"type" => "success", "text" => "Image Deleted Successfully !!!"} }
                        format.json { render json: {"type" => "success", "text" => "Image Deleted Successfully !!!"} }
                    else
                        format.html { render json: {"type" => "error", "text" => "Item Images Are Few !!!"} }
                        format.json { render json: {"type" => "error", "text" => "Item Images Are Few !!!"} }
                    end
                else
                    format.html { render json: {"type" => "error", "text" => "You are not the owner !!!"} }
                    format.json { render json: {"type" => "error", "text" => "You are not the owner !!!"} }
                end
            else
                format.html { render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"} }
                format.json { render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"} }
            end
        end
    end

    def destroy
        @item = Item.find(params[:id])
        if @active == true then
            if @item.user.id == session[:user_id] then
                @item.is_deleted = true
                @item.save
            end
        else
            flash[:danger] = "Your Private Account Is Not Active !!!"
        end
        redirect_to session_items_path
    end

    def like_item
        @like = ItemLike.new
        @like.item_id = params[:like][:item_id]
        @like.user_id = (is_logged_in?) ? session[:user_id] : params[:like][:session]
        user_id = (is_logged_in?) ? session[:user_id] : params[:like][:session]

        item = Item.find(params[:like][:item_id])
        
        check_like = ItemLike.where(user_id: user_id, item_id: params[:like][:item_id]).first

        if @active == true then
            if check_like == nil then
                if @like.save then
                    Notification.create([{user_from_id: session[:user_id], user_to_id: item.user.id, ressource: "item_like", ressource_id: item.id, is_read: false}])
                    render json: {"type" => "like", "text" => "Item Liked !!!"}
                else
                    render json: {"type" => "error", "error" => @like.errors.full_messages}
                end
            else
                check_like.destroy
                render json: {"type" => "dislike", "text" => "Item Disliked !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def like_item_destroy
        like = ItemLike.find(params[:id])
        if @active == true then
            if like != nil then
                if like.user.id == session[:user_id] then
                    like.destroy
                    render json: {"type" => "success", "text" => "Item Disliked !!!"}
                else
                    render json:{"type" => "error", "text" => "You Are Not The Owner !!!"}
                end
            else
                render json:{"type" => "error", "text" => "Item Like Not Found !!!"}
            end 
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def favourite_item
        @favourite = ItemFavourite.new
        @favourite.item_id = params[:favourite][:item_id]
        @favourite.user_id = session[:user_id]

        check_favourite = ItemFavourite.where(user_id: session[:user_id], item_id: params[:favourite][:item_id]).first

        if @active == true then
        
            if check_favourite == nil then
                if @favourite.save then
                    render json: {"type" => "success", "text" => "Item Marked as Favourite !!!"}
                else
                    render json: {"type" => "error", "error" => @favourite.errors.full_messages}
                end
            else
                check_favourite.destroy
                render json: {"type" => "unmark", "text" => "Item Unmarked as Favourite !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    def favourite_item_destroy
        favourite = ItemFavourite.find(params[:id])
        if @active == true then
            if favourite != nil then
                if favourite.user.id == session[:user_id] then
                    favourite.destroy
                    render json: {"type" => "success", "text" => "Item Unmarked as Favourite !!!"}
                else
                    render json: {"type" => "error", "text" => "You are not the Owner !!!"}
                end
            else
                render json: {"type" => "error", "text" => "404: Favourite Not Found !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
        end
    end

    private def item_params
        params.require(:item).permit(:name, :category_id, :subcategory_id, :price, :currency, :per, :description, :count, :sale_value)
    end
end