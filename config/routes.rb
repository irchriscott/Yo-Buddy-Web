Rails.application.routes.draw do

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

    get '/session/borrowed', to: 'session#borrowed', as: 'session_borrowed'
    get '/session/borrowing', to: 'session#borrowing', as: 'session_borrowing'
    get '/session/favourites', to: 'session#favourites', as: 'session_favourites'
    get '/session/likes', to: 'session#likes', as: 'session_likes'
    get '/session/followers', to: 'session#followers', as: 'session_followers'
    get '/session/following', to: 'session#following', as: 'session_following'
    get '/session/requests', to: 'session#requests', as: 'session_requests'

    get '/session/report/:ressource_id/get', to: 'session#report_new', as: 'report_new'
    post '/session/report/post', to: 'session#report_create', as: 'report_create'

 
  	resources :items do
        resources :comments
        resources :item_borrow_user do
            resources :borrow_messages
        end
    end

    get '/item/:username/enc-dt-:uuid-:id', to: 'items#show', as: 'item_show'
    get '/item/:username/enc-dt-:uuid-:id/edit', to: 'items#edit', as: 'item_edit'
    get '/item/:username/enc-dt-:uuid-:item_id/borrow', to: 'item_borrow_user#new', as: 'borrow_item'
    get '/item/:username/enc-dt-:uuid-:id/available', to: 'items#available', as: 'item_available'

    get '/item/:username/enc-dt-:uuid-:item_id/borrows', to: 'item_borrow_user#index', as: 'item_borrows'
    get '/item/enc-dt-:uuid-:item_id-:id/borrow', to: 'item_borrow_user#show', as: 'item_borrow'

    post '/items/:item_id/borrow_item_user/:item_borrow_user_id/borrow_messages/images/send', to: 'borrow_messages#send_images', as: 'message_send_images'

    get '/items/requests/all', to: 'item_requests#index', as: 'item_requests'
    get '/items/request/:id', to: 'item_requests#show', as: 'item_request'
    post '/items/request/:id/like', to: 'item_requests#like', as: 'item_request_like'
    get '/item/requests/new', to: 'item_requests#new', as: 'new_item_request'
    post '/item/requests/create', to: 'item_requests#create', as: 'create_item_request'
    get '/item/request/:id/edit', to: 'item_requests#edit', as: 'edit_item_request'
    get '/item/request/:item_request_id/image/:id/delete', to: 'item_requests#delete_item_request_image', as: 'delete_item_request_image'
    patch '/item/request/:id/update', to: 'item_requests#update', as: 'update_item_request'
    get '/item/request/:id/status/update', to: 'item_requests#update_request_status', as: 'update_item_request_status'
    delete '/item/request/:id/destroy', to: 'item_requests#destroy', as: 'destroy_item_request'
    get '/item/request/:id/suggestions/new', to: 'item_requests#suggestion_new', as: 'item_request_new_suggestion'
    get '/item/request/:id/suggestions/exist', to: 'item_requests#suggestion_exist', as: 'item_request_exist_suggestion'
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
    get '/user/:username-:id/borrowed', to: 'user#borrowed', as: 'user_borrows'
    get '/user/:username-:id/borrowing', to: 'user#borrowing', as: 'user_borrowing'
    get '/user/:username-:id/requests', to: 'user#requests', as: 'user_requests'
    post '/user/:id/follow', to: 'user#follow_user', as: 'user_follow'
    get '/user/get_and_update/user_s_data/from_token/in_the_application', to: 'user#update_from_api'

    resources :comments

    get '/categories/all', to: 'category#index', as: 'category_index'
    get '/category/enc-dt-:uuid-:id/subcategories', to: 'category#show', as: 'category'
    post '/category/:id/follow', to: 'category#follow', as: 'category_follow'
    get '/subcategories/all', to: 'subcategory#index', as: 'subcategory_index'
    get '/category/enc-dt-:uuid-:category_id-subcat-:id', to: 'subcategory#show', as: 'subcategory'

    post '/user/signup', to: 'user#signup', as: 'user_signup'

  	root 'home#index'
    get 'home/index'

    # ADMIN ROUTES

    get '/admin', to: 'admin#index', as: 'admin_index'
    post '/admin/signup', to: 'admin#signup', as: 'admin_signup'
    get '/admin/home', to: 'admin#home', as: 'admin_home'
    get '/admin/items', to: 'admin#items', as: 'admin_items'

    get '/admin/admins', to: 'admin#admins', as: 'admin_admins'
    post '/admin/admins/create', to: 'admin#create_admin', as: 'admin_create_admin'
    
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
