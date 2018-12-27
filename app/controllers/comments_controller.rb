class CommentsController < ApplicationController
    
    include ApplicationHelper

    before_action :check_session, only: [:edit]
    before_action :check_token, only: [:create, :update, :destroy]
    before_action :check_active
    skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]

    def index
        @item = Item.find(params[:item_id])
        @comments = @item.comment.all.order("created_at DESC")
        render layout: false
    end

    def show
    end

    def create
        @item = Item.find(params[:item_id])
        @comment = @item.comment.create(comment_params)
        CommentChannel.broadcast_to(@item, @comment)
        Notification.create([{user_from_id: session[:user_id], user_to_id: @item.user.id, ressource: "item_comment", ressource_id: @item.id, is_read: false}])
        render json:{"type" => "success", "text" => "Comment Saved !!!", "errors" => @comment.errors.full_messages }
    end

    def edit
        @comment = Comment.find(params[:id])
        render layout: false
    end

    def update
        @comment = Comment.find(params[:id])
        if @comment.user.id == session[:user_id] then
            if @comment.update(params[:comment].permit(:comment)) then
                render json:{"type" => "success", "text"=>"Comment Updated !!!"}
            else
                render json:{"type" => "error", "text"=> @comment.errors }
            end
        else
            render json:{"type" => "error", "text"=>"You are not the owner !!!"}
        end
    end

    def destroy
        @comment = Comment.find(params[:comment][:comment_id])
        if @comment.user.id == session[:user_id] then
            @comment.destroy
            render json:{"type" => "success", "text"=>"Comment Deleted !!!"}
        else
            render json:{"type" => "error", "text"=>"You are not the owner !!!"}
        end
    end

    private def comment_params
        params.require(:comment).permit(:comment, :user_id, :is_deleted)
    end

    def check_session
        if !is_logged_in? then
            render json:{"type" => "error", "text"=>"Please Log In !!!"}
        end
    end
end
