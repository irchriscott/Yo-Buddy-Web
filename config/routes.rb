Rails.application.routes.draw do

    require 'sidekiq/web'
    require 'sidekiq/cron/web'

    mount Sidekiq::Web => '/admin/sidekiq/report'

    get '/404', to: 'error#not_found_error', as: 'not_found_error', via: :all
    get '/500', to: 'error#internal_server_error', as: 'internal_server_error', via: :all

    root 'home#index'
    get 'home/index'
    get 'search/all', to:'home#search', as: 'search'
    get 'search/items', to: 'home#search_items', as: 'search_items'
    get 'search/requests', to: 'home#search_requests', as: 'search_requests'
    get 'search/users', to: 'home#search_users', as: 'search_users'
    post 'notification/send', to: 'home#notification_getway', as: 'notification_getway'

    get '/session', to: 'session#index', as: 'session'
    get '/session/profile', to: 'session#index', as: 'session_profile'
    get '/session/items', to: 'session#index', as: 'session_items'
    get '/session/edit/get', to: 'session#edit', as: 'session_edit'
    get '/session/logout', to: 'session#logout', as: 'session_logout'
    patch '/session/update/image', to: 'session#update_image', as: 'session_update_image'
    patch '/session/update/info', to: 'session#update_info', as: 'session_update_info'
    patch '/session/update/credintials', to: 'session#update_credintials', as: 'session_update_credintials'
    patch '/session/update/address', to: 'session#update_address', as: 'session_update_address'
    patch '/session/update/contact', to: 'session#update_contact', as: 'session_update_contact'

    get '/session/lending', to: 'session#borrowed', as: 'session_borrowed'
    get '/session/borrowing', to: 'session#borrowing', as: 'session_borrowing'
    get '/session/favourites', to: 'session#favourites', as: 'session_favourites'
    get '/session/likes', to: 'session#likes', as: 'session_likes'
    get '/session/followers', to: 'session#followers', as: 'session_followers'
    get '/session/following', to: 'session#following', as: 'session_following'
    get '/session/requests', to: 'session#requests', as: 'session_requests'
    get '/notifications/all', to: 'session#notifications_all', as: 'notifications_all'
    get '/notifications/items-requests', to:'session#notifications_item', as: 'notifications_item'
    get '/notifications/borrow', to: 'session#notifications_borrow', as: 'notifications_borrow'
    get '/notifications/reminder', to: 'session#notifications_reminder', as: 'notifications_reminder'

    get '/session/report/:ressource_id/get', to: 'session#report_new', as: 'report_new'
    post '/session/report/post', to: 'session#report_create', as: 'report_create'

 
  	resources :items do
        resources :comments
        resources :item_borrow_user do
            resources :borrow_messages
        end
    end

    post '/item/:item_id/comment/create', to: 'comments#create', as: 'create_item_comment'
    patch '/item/:item_id/comment/:id/update', to: 'comments#update', as: 'update_item_comment'
    delete '/item/:item_id/comment/:id/delete', to: 'comments#destroy', as: 'delete_item_comment'
    post '/items/:item_id/item_borrow_user/:item_borrow_user_id/borrow_messages/send', to: 'borrow_messages#create', as: 'send_message'

    post '/item/create', to: 'items#create', as: 'item_create'
    post '/item/:id/update', to:'items#update', as: 'item_update'

    get '/item/:username/enc-dt-:uuid-:id', to: 'items#show', as: 'item_show'
    get '/item/:username/enc-dt-:uuid-:id/ajax', to: 'items#show_ajax', as: 'item_show_ajax'
    get '/item/:username/enc-dt-:uuid-:id/edit', to: 'items#edit', as: 'item_edit'
    get '/item/:username/enc-dt-:uuid-:item_id/borrow', to: 'item_borrow_user#new', as: 'borrow_item'
    get '/item/:username/enc-dt-:uuid-:id/available', to: 'items#available', as: 'item_available'

    get '/item/:username/enc-dt-:uuid-:item_id/borrows', to: 'item_borrow_user#index', as: 'item_borrows'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow', to: 'item_borrow_user#show', as: 'item_borrow'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow/review', to: 'item_borrow_user#borrow_review', as: 'borrow_review'
    post '/item/enc-dt-:uuid-:item_id/borrow/create', to: 'item_borrow_user#create', as: 'create_item_borrow'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow/description', to: 'item_borrow_user#description', as: 'item_borrow_description'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow/description/download.pdf', to: 'item_borrow_user#download_borrow_data', as: 'item_borrow_description_download'

    get '/item/enc-dt-:uuid-:item_id-:id/borrow/extend', to: 'item_borrow_user#extend', as: 'item_borrow_extend'
    post '/item/enc-dt-:uuid-:item_id-:id/borrow/extend/post', to: 'item_borrow_user#extend_borrow', as: 'extend_borrow_post'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow/extend/status/update', to: 'item_borrow_user#update_borrow_extension_status', as: 'update_borrow_extension_status'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow/renew', to: 'item_borrow_user#extend', as: 'item_borrow_renew'
    post '/item/enc-dt-:uuid-:item_id-:id/borrow/renew/post', to: 'item_borrow_user#renew_borrow', as: 'renew_borrow_post'

    get '/items/enc-dt-:uuid-:item_id-:item_borrow_user_id/follow-ups', to: 'item_borrow_user#follow_ups', as: 'follow_ups'
    get '/items/:item_id/borrow/:item_borrow_user_id/follow-ups/sent', to: 'item_borrow_user#load_follow_ups_sent', as: 'load_follow_ups_sent'
    get '/items/:item_id/borrow/:item_borrow_user_id/follow-ups/received', to: 'item_borrow_user#load_follow_ups_received', as: 'load_follow_ups_received'
    post '/items/:item_id/borrow/:item_borrow_user_id/follow-ups/send', to: 'item_borrow_user#send_follow_up', as: 'send_follow_up'

    get '/items/enc-dt-:uuid-:item_id-:item_borrow_user_id/messages/admin', to: 'borrow_messages#admin_messages', as: 'admin_messages'
    get '/items/enc-dt-:uuid-:item_id-:item_borrow_user_id/messages/admin/load', to: 'borrow_messages#load_admin_messages', as: 'load_admin_messages'
    post '/items/:item_id/borrow_item_user/:item_borrow_user_id/borrow_messages/images/send', to: 'borrow_messages#send_images', as: 'message_send_images'
    post '/items/:item_id/borrow_item_user/:item_borrow_user_id/borrow_messages/admin/send', to: 'borrow_messages#send_admin_message', as: 'message_send_admin'

    get '/items/requests/all', to: 'item_requests#index', as: 'item_requests'
    get '/items/request/:username/enc-dt-:uuid-:id', to: 'item_requests#show', as: 'item_request'
    get '/items/request/:username/enc-dt-:uuid-:id/ajax', to: 'item_requests#show_ajax', as: 'item_request_ajax'
    post '/items/request/:id/like', to: 'item_requests#like', as: 'item_request_like'
    get '/item/requests/new', to: 'item_requests#new', as: 'new_item_request'
    post '/item/requests/create', to: 'item_requests#create', as: 'create_item_request'
    get '/item/request/:username/enc-dt-:uuid-:id/edit', to: 'item_requests#edit', as: 'edit_item_request'
    get '/item/request/:item_request_id/image/:id/delete', to: 'item_requests#delete_item_request_image', as: 'delete_item_request_image'
    patch '/item/request/:id/update', to: 'item_requests#update', as: 'update_item_request'
    get '/item/request/:id/status/update', to: 'item_requests#update_request_status', as: 'update_item_request_status'
    delete '/item/request/:id/destroy', to: 'item_requests#destroy', as: 'destroy_item_request'
    get '/item/request/:username/enc-dt-:uuid-:id/suggestions/new', to: 'item_requests#suggestion_new', as: 'item_request_new_suggestion'
    get '/item/request/:username/enc-dt-:uuid-:id/suggestions/exist', to: 'item_requests#suggestion_exist', as: 'item_request_exist_suggestion'
    post '/item/request/:id/suggestions/create', to: 'item_requests#suggestion_create', as: 'item_request_create_suggestion'
    post '/item/request/:id/suggestions/create/exist', to: 'item_requests#suggesion_create_exist', as: 'item_request_create_exist_suggestion'
    get '/item/request/:id/suggestions/all', to: 'item_requests#suggestion_all', as: 'item_request_suggestions'
    get '/item/request/:item_request_id/suggestion/:id/edit', to: 'item_requests#suggestion_edit', as: 'item_request_suggestion_edit'
    patch '/item/request/:item_request_id/suggestion/:id/update', to: 'item_requests#suggestion_update', as: 'item_request_suggestion_update'
    get '/item/request/:item_request_id/suggestion/:id/status/update', to: 'item_requests#suggestion_update_status', as: 'item_request_suggestion_update_status'

    get '/items/:item_id/item_borrow_user/:item_borrow_user_id/all', to: 'borrow_messages#borrow_all', as: 'borrow_messages_all'
    get '/items/:item_id/item_borrow_user/:id/update_status', to: 'item_borrow_user#update_status', as: 'update_status'
    post '/items/:item_id/item_borrow_user/:id/update', to: 'item_borrow_user#update', as: 'update_item_borrow_item_user'
    get '/items/:item_id/item_borrow_user/:id/delete', to: 'item_borrow_user#destroy', as: 'destroy_item_borrow_item_user'

    post '/comments/:id/delete', to: 'comments#destroy', as: 'delete_comment'
    get '/item/:item_id/image/:id/delete', to: 'items#delete_image_item', as: 'delete_item_image'

    post '/item/:id/like', to: 'items#like_item', as: 'like'
    get '/item/:item_id/like/:id/destroy', to: 'items#like_item_destroy', as: 'like_destroy'
    post '/item/:id/favourite', to: 'items#favourite_item', as: 'favourite'
    get '/item/:item_id/favourite/:id/destroy', to: 'items#favourite_item_destroy', as: 'favourite_destroy'

    get '/users/all', to: 'user#index', as: 'users'

    resources :user

    get '/user/:username-:id/items', to: 'user#show', as: 'user_items'
    get '/user/:username-:id/likes', to: 'user#likes', as: 'user_likes'
    get '/user/:username-:id/followers', to: 'user#followers', as: 'user_followers'
    get '/user/:username-:id/following', to: 'user#following', as: 'user_following'
    get '/user/:username-:id/lending', to: 'user#borrowed', as: 'user_borrows'
    get '/user/:username-:id/borrowing', to: 'user#borrowing', as: 'user_borrowing'
    get '/user/:username-:id/requests', to: 'user#requests', as: 'user_requests'
    post '/user/:id/follow', to: 'user#follow_user', as: 'user_follow'
    get '/user/get_and_update/user_s_data/from_token/in_the_application', to: 'user#update_from_api'

    get '/user/password/reset', to:'user#reset_password', as: 'user_reset_password'
    post '/user/password/reset/mail/send', to: 'user#send_reset_password_mail', as: 'user_rp_send_mail'
    get '/user/password/reset/dt-token-:token/form', to: 'user#reset_password_form', as: 'user_rp_link'
    post '/user/password/reset/change', to: 'user#reset_change_password', as: 'user_reset_password_change'

    resources :comments

    get '/categories/all', to: 'category#index', as: 'category_index'
    get '/category/enc-dt-:uuid-:id/subcategories', to: 'category#show', as: 'category'
    post '/category/:id/follow', to: 'category#follow', as: 'category_follow'
    get '/subcategories/all', to: 'subcategory#index', as: 'subcategory_index'
    get '/category/enc-dt-:uuid-:category_id-subcat-:id', to: 'subcategory#show', as: 'subcategory'

    post '/user/signup', to: 'user#signup', as: 'user_signup'

    #ADMIN USERS ROUTES

    get '/admin/u/signin', to: 'admin_user#index', as: 'admin_u_index'
    post '/admin/u/signin/post', to: 'admin_user#signin', as: 'admin_u_signin'
    get '/admin/u', to: 'admin_user#home', as: 'admin_u'
    get '/admin/u/home', to: 'admin_user#home', as: 'admin_u_home'
    get '/admin/u/items', to: 'admin_user#items', as: 'admin_u_items'
    get '/admin/u/borrows', to: 'admin_user#borrows', as: 'admin_u_borrows'
    get '/admin/u/logout', to: 'admin_user#logout', as: 'admin_u_logout'

    get '/admin/u/password/reset', to:'admin_user#reset_password', as: 'admin_u_reset_password'
    post '/admin/u/password/reset/mail/send', to: 'admin_user#send_reset_password_mail', as: 'admin_u_rp_send_mail'
    get '/admin/u/password/reset/dt-token-:token/form', to: 'admin_user#reset_password_form', as: 'admin_u_rp_link'
    post '/admin/u/password/reset/change', to: 'admin_user#reset_change_password', as: 'admin_u_reset_password_change'

    get 'admin/u/item/:username/enc-dt-:uuid-:id/borrows', to: 'admin_user#item', as: 'admin_u_item'
    get 'admin/u/item/enc-dt-:uuid-:item_id-:id/borrow', to: 'admin_user#borrow', as: 'admin_u_borrow'
    post '/admin/u/item/:item_id/borrow/:id/item/check', to: 'admin_user#borrow_check_item', as: 'admin_u_borrow_check_item'
    post '/admin/u/item/:item_id/borrow/:id/message/create', to: 'admin_user#borrow_item_admin_create', as: 'admin_u_create_message'
    post '/admin/u/item/:item_id/borrow/:id/item/add', to: 'admin_user#add_item', as: 'admin_u_add_item'
    get '/admin/u/item/:item_id/borrow/:id/act/received', to: 'admin_user#borrow_act_received', as: 'admin_u_borrow_act_received'
    get '/admin/u/item/:item_id/borrow/:id/act/rendered', to: 'admin_user#borrow_act_rendered', as: 'admin_u_borrow_act_rendered'
    get '/admin/u/item/borrow/enc-dt-:uuid-:item_id-:id/act/received/download.pdf', to: 'admin_user#download_borrow_act_received', as: 'admin_u_borrow_act_received_download'
    get '/admin/u/item/borrow/enc-dt-:uuid-:item_id-:id/act/rendered/download.pdf', to: 'admin_user#download_borrow_act_rendered', as: 'admin_u_borrow_act_rendered_download'

    get '/admin/u/borrows/scan/get', to: 'admin_user#scan_borrow', as: 'admin_u_scan_borrow'
    post '/admin/u/borrows/scan/post', to: 'admin_user#scan_borrow_post', as: 'admin_u_scan_borrow_post'
    get '/admin/u/item/:username/enc-dt-:uuid-:item_id/borrow', to: 'admin_user#new_borrow', as: 'admin_u_borrow_item_new'
    post '/admin/u/item/enc-dt-:uuid-:item_id/borrow/create', to: 'admin_user#create_borrow', as: 'admin_u_borrow_item_create'
    get '/admin/u/borrow/user/find.json', to: 'admin_user#search_user', as: 'admin_u_borrow_user_find'
    
    get '/admin/u/activation/key', to: 'admin_user#set_activation', as: 'admin_u_activation'
    post '/admin/u/activate/key', to: 'admin_user#activate_key', as: 'admin_u_activate_key'

    # ADMIN ROUTES

    get '/admin', to: 'admin#index', as: 'admin_index'
    post '/admin/signin', to: 'admin#signup', as: 'admin_signup'
    get '/admin/home', to: 'admin#home', as: 'admin_home'
    get '/admin/items', to: 'admin#items', as: 'admin_items'
    get '/admin/logout', to: 'admin#logout', as: 'admin_logout'

    get '/admin/password/reset', to:'admin#reset_password', as: 'admin_reset_password'
    post '/admin/password/reset/mail/send', to: 'admin#send_reset_password_mail', as: 'admin_rp_send_mail'
    get '/admin/password/reset/dt-token-:token/form', to: 'admin#reset_password_form', as: 'admin_rp_link'
    post '/admin/password/reset/change', to: 'admin#reset_change_password', as: 'admin_reset_password_change'

    get '/admin/admins', to: 'admin#admins', as: 'admin_admins'
    post '/admin/admins/create', to: 'admin#create_admin', as: 'admin_create_admin'
    post '/admin/admins/u/create', to: 'admin#create_admin_user', as: 'admin_u_create'
    get '/admin/admin/u/:usernane-:id', to: 'admin#show_admin_user', as: 'admin_show_admin_u'
    get '/admin/admins/u/create/find.json', to: 'admin#search_user', as: 'admin_u_find'
    get '/admin/admin/u/:usernane-:user_id/key/new', to: 'admin#key_new', as: 'admin_u_key_new'
    post '/admin/admin/u/key/add', to: 'admin#key_new_add', as: 'admin_u_key_new_add'

    get '/admin/borrows', to: 'admin#borrows_all', as: 'admin_borrows_all'
    get '/admin/borrows/scan/get', to: 'admin#scan_borrow', as: 'admin_scan_borrow'
    post '/admin/borrows/scan/post', to: 'admin#scan_borrow_post', as: 'admin_scan_borrow_post'
    get '/admin/item/:id/borrows', to: 'admin#borrows_item', as: 'admin_item_borrows'
    get '/admin/item/:item_id/borrow/:id', to: 'admin#borrow', as: 'admin_borrow'
    post '/admin/item/:item_id/borrow/:id/item/check', to: 'admin#borrow_check_item', as: 'admin_borrow_check_item'
    post '/admin/item/:item_id/borrow/:id/message/create', to: 'admin#borrow_item_admin_create', as: 'admin_create_message'
    post '/admin/item/:item_id/borrow/:id/item/add', to: 'admin#add_item', as: 'admin_add_item'
    get '/admin/item/:item_id/borrow/:id/act/received', to: 'admin#borrow_act_received', as: 'admin_borrow_act_received'
    get '/admin/item/:item_id/borrow/:id/act/rendered', to: 'admin#borrow_act_rendered', as: 'admin_borrow_act_rendered'
    get '/admin/item/:item_id/borrow/:id/act/received/download.pdf', to: 'admin#download_borrow_act_received', as: 'admin_borrow_act_received_download'
    get '/admin/item/:item_id/borrow/:id/act/rendered/download.pdf', to: 'admin#download_borrow_act_rendered', as: 'admin_borrow_act_rendered_download'
    
    get '/admin/categories', to: 'admin#categories', as: 'admin_categories'
    get '/admin/categories/new', to: 'admin#new_category', as: 'admin_new_category'
    get '/admin/category/:id', to: 'admin#category', as: 'admin_category'
    post '/admin/categories/create', to: 'admin#create_category', as: 'admin_create_category'
    get '/admin/category/:id/edit', to: 'admin#edit_category', as: 'admin_edit_category'
    patch '/admin/category/:id/update', to: 'admin#update_category', as: 'admin_update_category'
    
    get '/admin/subcategories', to: 'admin#subcategories', as: 'admin_subcategories'
    get '/admin/category/:category_id/subcategory/:id', to: 'admin#subcategory', as: 'admin_subcategory'
    get '/admin/category/:category_id/subcategories/new', to: 'admin#new_subcategory', as: 'admin_new_subcategory'
    post '/admin/category/:category_id/subcategories/create', to: 'admin#create_subcategory', as: 'admin_create_subcategory'
  	
    get '/admin/item/:id', to: 'admin#item', as: 'admin_item'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end