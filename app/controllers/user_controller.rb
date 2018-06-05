require 'securerandom'

class UserController < ApplicationController

    before_action :set_user, only: [:show, :likes, :followers, :following, :get_borrowed, :borrowed, :get_borrowing, :borrowing, :requests]
    skip_before_action :verify_authenticity_token
    before_action :check_token, only: [:follow_user]

    def index
        @users = User.all.order(name: :asc)
    end

    def new
        if !session[:user_id] then
            @user = User.new
            if params[:layout] == "false" then
                render layout: false
            end
        else
            redirect_to controller: 'session', action: 'index'
        end
    end

    def create

        @user = User.new(params[:user].permit(:name, :username, :email, :country, :town, :password, :is_private))
        @user.is_authenticated = false
        @user.is_blocked = false
        @user.token = SecureRandom.urlsafe_base64(@user.name.length + @user.username.length + @user.email.length)

        check_user_email = User.find_by(email: params[:user][:email])
        check_user_username = User.find_by username: params[:user][:username]
        
        respond_to do |format|
            if check_user_email == nil then
                if check_user_username == nil then
                    if @user.save then
                        format.html { redirect_to new_user_path, success: 'User Registred Successfully !!!' }
                        format.json { render json:{"type" => "success", "text" => @user} }
                        flash[:success] = 'User Registred Successfully !!!'
                    else
                        format.html { redirect_to new_user_path, danger: @user.errors.full_messages }
                        format.json { render json: {"type" => "error", "text" => @user.errors}, status: :unprocessable_entity }
                        flash[:danger] = @user.errors.full_messages
                    end
                else
                    format.html { redirect_to new_user_path, danger: 'Username Already Taken !!!' }
                    format.json { render json: {"type" => "error", "text" => "Username Already Taken !!!"}, status: :unprocessable_entity }
                    flash[:danger] = 'Username Already Taken !!!'
                end
            else
                format.html { redirect_to new_user_path, danger: 'Email Already Taken !!!' }
                format.json { render json: {"type" => "error", "text" => "Email Already Taken !!!"}, status: :unprocessable_entity }
                flash[:danger] = 'Email Already Taken !!!'
            end
        end
    end

    def show
        @items = @user.item.all.order(created_at: :desc)
        if is_logged_in? then
            if @user.id == session[:user_id] then
                redirect_to session_items_path
            end
        end
    end

    def likes
        @likes = @user.item_like.all.order(created_at: :desc)
    end
    
    def followers
        @followers = UserFollow.where(following_id: @user.id)
    end

    def following
        @following = UserFollow.where(user_id: @user.id)
    end

    def requests
        @requests = @user.item_request.all.order(to_date: :asc)
        @activate = "requests"
    end

    def borrowed
        @borrowed = get_borrowed
        @activate = "borrowed"
    end

    def borrowing
        @borrows = get_borrowing
        @activate = "borrowing"
    end

    def follow_user
        if is_logged_in? or params[:token] then
            user_id = (is_logged_in?) ? session[:user_id] : params[:follow][:session]
            check_follow = UserFollow.where(user_id: user_id, following_id: params[:follow][:following_id]).first
            if check_follow == nil then
                follow = UserFollow.new(params[:follow].permit(:following_id))
                follow.user_id = (is_logged_in?) ? session[:user_id] : params[:follow][:session]
                follow.save
                render json: {"type" => "follow", "text" => "User Followed !!!"}
            else
                check_follow.destroy
                render json: {"type" => "unfollow", "text" => "User Unfollowed !!!"}
            end
        else
            render json: {"type" => "error", "text" => "Loggin Please !!!!"}
        end
    end

    def signup
        user = User.find_by(email: params[:user][:email].downcase)
        respond_to do |format|
            if user then
                if user.authenticate(params[:user][:password]) then
                    login user
                    format.html { redirect_to root_path, success: 'User Logged In Successfully !!!' }
                    format.json {  render json: {"type" => "success", "text" => "Logged In Successfully !!!", "user" => user.json, "token" => user.token} }
                    flash[:success] = 'User Logged In Successfully !!!'
                else
                    format.html { redirect_to new_user_path, danger: 'Invalid Password !!!' }
                    format.json { render json: {"type" => "error", "text" => "Invalid Password !!!"} }
                    flash[:danger] = 'Invalid Password !!!'
                end
            else
                format.html { redirect_to new_user_path, danger: 'Unknown Email Address !!!' }
                format.json { render json: {"type" => "error", "text" => "Unknown Email Address !!!"} }
                flash[:danger] = 'Unknown Email Address !!!'
            end
        end
    end

    private def user_params
        params.require(:user).permit(:name, :username, :email, :country, :town, :password, :is_private)
    end

    def get_borrowed
        borrowed = Array.new
        if is_logged_in? then
            session_user.borrow_item_user.all.order(created_at: :desc).each do |borrow|
                if borrow.item.user.id == @user.id then
                    borrowed.append(borrow)
                end
            end
        end
        return borrowed
    end

    def get_borrowing
        borrowing = Array.new
        if is_logged_in? then
            @user.borrow_item_user.all.order(created_at: :desc).each do |borrow|
                if borrow.item.user.id == session_user.id then
                    borrowing.append(borrow)
                end
            end
        end
        return borrowing
    end

    def update_from_api
        token = params[:token]
        begin
            user = User.find_by(token: token).first
            if user then
                render json: user.json
            else
                render json: 404
            end
        rescue Exception => e
            render json: 404
        end
    end

    private def set_user
        @user = User.find(params[:id])
        @borrowed_count = get_borrowed.length
        @borrowing_count = get_borrowing.length
        @requests_count = 0
    end
end
