/**
	Main Stylesheet for Yo Buddy !
	Date: Saturday, 29th March 2018
	Author: Ir Christian Scott
**/

const socket = io("127.0.0.1:5000");

let sessionID = null;
let sessionUsername = null;
let sessionName = null;

$(function() {

    var contID = $("body").find("#session_user_id");
    var contName = $("body").find("#session_name");
    var contUsername = $("body").find("#session_username");

    if(contID.length > 0){
        sessionID = contID.val();
        sessionUsername = contUsername.val();
        sessionName = contName.val();
    }

    $(document).on("keyup", function(e){
        if(e.keyCode === 27) {
            $(document).find(".yb-item-menu-list, .yb-menu-list").fadeOut();
            $("#yb-search-overlay, #yb-search-container, #yb-search-form-spinner").hide();
            $("html, body").removeClass("yb-hide-sb");
        }
        if((e.shiftKey || e.altKey) && e.keyCode === 83){
            $("html, body").addClass("yb-hide-sb");
            $("#yb-search-overlay, #yb-search-container").show().find("input").focus();
        }
    });

    $(document).ready(function() {

        $('#yb-home-main, #yb-user-sign').backstretch(
        [
            "/assets/slide/slide_1.jpg",
            "/assets/slide/slide_2.jpg",
            "/assets/slide/slide_3.jpg",
        ],
        {
            duration: 2000,
            fade: 750
        });
    });

    //SHOW MOBILE SIDEBAR

    $("#yb-sidebar-toggle").click(function(e){
        e.stopPropagation();
        $("#yb-sidebar-navigation").addClass("yb-navigation-open");
        $("html, body").addClass("yb-hide-sb");
        $("#yb-sidebar-ovarlay").show();
    });

    $("#yb-sidebar-ovarlay").click(function(e){
        e.preventDefault();
        $(this).hide();
        $("#yb-sidebar-navigation").removeClass("yb-navigation-open");
        $("html, body").removeClass("yb-hide-sb");
    });

    //SEARCH TOGGLE

    $("#yb-seach-toggle").click(function(e){
        e.stopPropagation();
        $("html, body").addClass("yb-hide-sb");
        $("#yb-search-overlay, #yb-search-container").show().find("input").focus();
    });

    $("#yb-search-overlay").click(function(e){
        e.preventDefault();
        $(this).hide();
        $("#yb-search-container, #yb-search-form-spinner").hide();
        $("html, body").removeClass("yb-hide-sb");
    });

    //LOGIN MENU

    $(".yb-sign-menu ul li a").click(function(e){
        e.preventDefault();
        var target = $(this).attr("href");
        var parent = $(this).parent("li")
        $(this).parent("li").addClass("active").siblings().removeClass("active");
        $(".yb-sign-content " + target).addClass("active").siblings().removeClass("active");
    });

    //TELL INPUT

    $("#user_number").intlTelInput({
        initialCountry: "auto",
        geoIpLookup: function(callback) {
            $.get('http://ipinfo.io', function() {}, "jsonp").always(function(resp) {
                var countryCode = (resp && resp.country) ? resp.country : "";
                callback(countryCode);
            });
        },
    });

    var set_country_code = setInterval(function(){
        if($(".intl-tel-input .country-list").length > 0){
            $(".intl-tel-input .country-list li").each(function(){
                if($(this).hasClass('active')){
                    var country_code = $(this).attr("data-dial-code");
                    $("#user_number").val("+"+country_code);
                }
            });
        }
    });

    setInterval(function(){
        if($("#user_number").val() != ""){
            clearInterval(set_country_code);
        }else{
            setInterval(set_country_code);
        }
    });

    $(".intl-tel-input .country-list li").click(function(){
        var country_code = $(this).attr("data-dial-code");
        $("#user_number").val("+" + country_code);
    });

    //PREVIEW PROFILE IMG

    $("#upload_image").click(function(e){
        e.preventDefault()
        $("#user_image").click();
    });

    $("#user_image").change(function(){
        previewImage(this, "profile_image");
    });

    $("#yb-open-borrow-item-description, #yb-add-item-new, #admin-add-new-item, #admin-user-edit-item, #yb-add-item-request-new, #yb-edit-item-path, #yb-item-check-available, #yb-new-item-borrow-user-path, #yb-edit-borrow-item, #admin-add-category, #admin-add-subcategory, #admin-edit-category, #yb-admin-act-received, #yb-admin-act-rendered, #admin-open-scan-borrow, #yb-add-suggestion-new, #yb-add-suggestion-exist, #yb-get-report, #yb-get-report-else, #yb-admin-key-new").magnificPopup({type:'ajax'});

    $("#admin-add-admin-user, #yb-admin-open-add-message, #admin-add-admin, #yb-borrow-get-qr-code, #yb-add-item-admin, #yb-view-item-admin, #yb-admin-open-scan-qr-code, #yb-open-send-message-images").magnificPopup({
        type: 'inline',
        fixedContentPos: false,
        fixedBgPos: true,
        overflowY: 'auto',
        closeBtnInside: true,
        preloader: false,
        midClick: true,
        removalDelay: 300,
        mainClass: 'my-mfp-zoom-in'
    });

    $("#some_tags").magnificPopup({
        type: 'image',
        closeOnContentClick: true,
        closeBtnInside: false,
        fixedContentPos: true,
        mainClass: 'mfp-no-margins mfp-with-zoom',
        image: {
            verticalFit: true
        },
        zoom: {
            enabled: true,
            duration: 300
        }
    });

    $(".like-item").likeItem();
    $(".like-form").likeItemEvent();
    $(".like-item-request").likeItemRequest();
    $(".like-request-form").likeItemRequestEvent();

    $(".yb-single-images ul li a").click(function(e){
        e.preventDefault();
        var image = $(this).attr("href");
        var id = $(this).attr("data-image-id");
        $(this).parent("li").addClass("activated").siblings().removeClass("activated");
        $("#item_image_main").attr("src", image);
        $("#item_image_main").parent(".yb-single-image").attr("data-image-id", id);
    });

    $(".yb-single-image").click(function(e){
        e.preventDefault();
        var images = $("#yb-item-images-gallery").find("a");
        var id = $(this).attr("data-image-id");
        for(let i = 0; i <= images.length; i++){
            if($(images[i]).attr("data-image-id") == id){
                $(images[i]).click();
            }
        }
    });

    $("#yb-show-session-menu").showMenu();
    $("#item_date").setDate();
    $("#item_price").setNumber();
    $("#item_price_min").setNumber();
    $("#item_price_max").setNumber();
    $("#number_likes").setNumber();
    $("#number_comments").setNumber();
    $("#number_borrow").setNumber();
    $("#yb-item-menu-item").showMenu();
    $("#yb-borrow-show-menu").showMenu();
    $("#yb-borrow-menu-other").showMenu();
    $("#yb-open-session-add-menu").showMenu();
    $("#yb-borrow-single-price").setNumber();
    $("#yb-borrow-total-price").setNumber();
    $("#yb-request-date").setDate();
    $("#yb-borrow-message-form").messageText();
    $("#admin-item-date").setDate();
    $("#admin-item-price").setNumber();
    $(".yb-btn-cancel").closePopup();
    $("#yb-favourite-item-form").favoutiteItem();
    $("#yb-user-follow-container-user").followUser(); 
    $("#yb-user-follow-form-user").followUserEvent();
    $("#yb-user-follow-category-container").followCategory();
    $("#yb-user-follow-category-form-user").followCategoryEvent();
    $("#yb-categories-list").activateList();
    $("#yb-user-else-menu").activateList();
    $("#yb-borrow-image-message-form").messageText();
    $("#yb-open-message-menu").showMenu();
    $("#yb-add-admin-user-form").searchAdminUser();
    $("#yb-number-else").setNumber();
    $("#yb-number-else-yb").setNumber();
    $(".yb-update-borrow-status-link").updateBorrowItemUserStatus();
    $("#yb-item-images-gallery").imagesGallery();
    $("#yb-live-search").ybLiveSeacrh();

    $("#search_borrow_category").change(function(){
        filterSubcategories($(this), $("#search_borrow_subcategory"));
    });

    $("#yb-print-borrow-description").click(function(e){
        e.preventDefault();
        window.location = $(this).attr("data-url");
    });

    $("#yb-admin-open-scan-qr-code").click(function(e){
        e.preventDefault();
        $(".yb-qr-preview-container").show();
        var scanner = new Instascan.Scanner({ video: document.getElementById('preview-qr-code'), scanPeriod: 5 });
        scanner.addListener('scan', function (data) {
            $("#item_scan_code").val(data);
            $("#yb-admin-submit-item-check").click();
        });
        Instascan.Camera.getCameras().then(function (cameras) {
            if (cameras.length > 0) {
                scanner.start(cameras[0]);
            } else {
                showErrorMessage("error", "No Camera Found");
            }
        }).catch(function (e) {
            showErrorMessage("error", e.toString());
        });
    });

    $("#yb-admin-item-scan-check").submit(function(e){
        e.preventDefault();
        var url = $(this).attr("action");
        var data = new FormData($(this)[0]);
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    $("#yb-item-is-authenticated-" + response.item).html('<i class="icon ion-checkmark-round" style="color:green;"></i>');
                    showSuccessMessage("success", response.text);
                } else if(response.type == "wrong"){
                    showInfoMessage("info", response.text);
                    window.location = response.url;
                } else {
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });

    $("#yb-favourite-item, #yb-favourite-item-else").click(function(e){
        e.preventDefault();
        $("#yb-favourite-item-form").submit();
    });

    //SHOW & SUBMIT COMMENTS

    $("#new_comment").postItemComment();

    socket.on("getNotification", function(owner){
        if(sessionID == owner){
            var contNot = $("body").find("#yb-session-notifications");
            contNot.fadeIn();
            contNot.text(parseInt(contNot.text()) + 1);
        }
    });

    socket.on("getComment", function(comment){
        var container = $("body").find("#yb-item-comments");
        var url = container.attr("data-url");
        var item = container.attr("data-item");

        if(comment.url == url && comment.item == item){
            setLoadData("yb-item-comments", comment.url);
            var comments = $("body").find(".comment-sum-" + item);
            if(comment.from == "add"){
                sum = parseInt(comments.attr("data-number")) + 1;
            } else if(comment.from == "delete"){
                sum = parseInt(comments.attr("data-number")) - 1;
            } else {
                sum = parseInt(comments.attr("data-number"));
            }
            comments.attr("data-number", sum);
            comments.setNumber();
        }
    });

    socket.on("getSuggestion", function(suggestion){
        var container = $("body").find("#yb-item-request-sugestions");
        var url = container.attr("data-url");
        var request = container.attr("data-request");

        if(suggestion.url == url && suggestion.request == request){
            setLoadData("yb-item-request-sugestions", suggestion.url);
            if (suggestion.from != "update"){
                var suggestions = $("body").find(".suggestions-sum-" + request);
                var sum = parseInt(suggestions.attr("data-number")) + 1;
                suggestions.attr("data-number", sum);
                suggestions.setNumber();
            }
        }
        var session = $("#session_user_id").val();
        if(session == suggestion.owner){
            iziToast.info({
                id: suggestion.owner,
                timeout: 5000,
                title: suggestion.user,
                message: (suggestion.from != "update") ? "Has Suggested On Your Item Request !!!" : "Has Updated His Suggestion On Your Item Request !!!",
                position: 'bottomLeft',
                transitionIn: 'bounceInLeft',
                close: false,
            });
        }
    });

    socket.on("getLike", function(like){
        console.log(like);
        var container = $("body").find(".like-sum-" + like.item);
        var sum = parseInt(container.attr("data-number"));
        if(like.type == "like"){
            container.attr("data-number", sum + 1);
        } else {
            container.attr("data-number", sum - 1);
        }
        container.setNumber();
        var session = $("#session_user_id").val();

        if(session == like.user){
            iziToast.info({
                id: like.user,
                timeout: 5000,
                title: like.liker,
                message: "Has Liked Your Item !!!",
                position: 'bottomLeft',
                transitionIn: 'bounceInLeft',
                close: false,
            });
        }
    });

    socket.on("rgetLike", function(like){
        var container = $("body").find(".like-request-sum-" + like.item);
        var sum = parseInt(container.attr("data-number"))
        if(like.type == "like"){
            container.attr("data-number", sum + 1);
        } else {
            container.attr("data-number", sum - 1);
        }
        container.setNumber();
        var session = $("#session_user_id").val();

        if(session == like.user){
            iziToast.info({
                id: like.user,
                timeout: 5000,
                title: like.liker,
                message: "Has Liked Your Item Request !!!",
                position: 'bottomLeft',
                transitionIn: 'bounceInLeft',
                close: false,
            });
        }
    });

    socket.on("isTyping", function(data){
        var receiver = $("#session_user_id").val();
        var form = $("body").find("#yb-borrow-message-form");
        if(data.receiver == receiver){
            if(form.length > 0){
                var item = form.attr("data-item");
                var borrow = form.attr("data-borrow");
                if(item == data.item && borrow == data.borrow){
                    var paragraph = $("#yb-type-status");
                    if(data.message != ""){
                        paragraph.fadeIn().children("p").text(capitalize(data.sender) + " is typing...")
                    } else {
                        paragraph.fadeOut().children("p").text("");
                    }
                }
            }
        }
    });

    socket.on("getMessage", function(message){
        var receiver = $("#session_user_id").val();
        var form = $("body").find("#yb-borrow-message-form");
        if(message.receiver == receiver){
            if(form.length > 0){
                var item = form.attr("data-item");
                var borrow = form.attr("data-borrow");
                if(item == message.item && borrow == message.borrow){
                    setLoadData("yb-borrow-messages-container", message.url);
                    updateMessageScroll();
                } else {
                    iziToast.info({
                        id: message.borrow,
                        timeout: 8000,
                        title: message.sender,
                        message: message.message,
                        position: 'bottomLeft',
                        transitionIn: 'bounceInLeft',
                        close: false,
                    });
                }
                if (message.type == "status"){
                    iziToast.info({
                        id: message.borrow,
                        timeout: 8000,
                        title: message.sender,
                        message: message.message,
                        position: 'bottomLeft',
                        transitionIn: 'bounceInLeft',
                        close: false,
                    });
                }
            } else {
                iziToast.info({
                    id: message.borrow,
                    timeout: 8000,
                    title: message.sender,
                    message: message.message,
                    position: 'bottomLeft',
                    transitionIn: 'bounceInLeft',
                    close: false,
                });
            }
        } else if (message.sender == form.attr("data-sender")){
            setLoadData("yb-borrow-messages-container", message.url);
        }
    });

    socket.on("getFollower", function(user){
        var session = $("#session_user_id").val();
        if(session == user.id){
            if(user.type == "follow"){
                showInfoMessage("info", user.user + " has started following you !!!");
            } else if(user.type == "unfollow"){
                showInfoMessage("info", user.user + " has unfollowed you !!!");
            }
        }
    });

    socket.on("getSuggestionUpdate", function(data){
        var session = $("#session_user_id").val();
        setLoadData("yb-item-request-sugestions", data.url);
        if(session == data.owner){
            switch(data.about){
                case "suggestion-status":
                    iziToast.info({
                        id: data.about,
                        timeout: 5000,
                        title: data.user,
                        message: " Has updated your suggestion status to " + data.status + " !!!",
                        position: 'bottomLeft',
                        transitionIn: 'bounceInLeft',
                        close: false,
                    });
                default:
                    console.log("notification fired")
            }
        }
    });

    $(window).scroll(function(e){
        if($(this).scrollTop() > 5.454545497894287){
            $(".yb-header-else").show();
        } else {
            $(".yb-header-else").hide();
        }

        if($(this).scrollTop() > 20){
            $(".yb-header-admin-else").show();
        } else {
            $(".yb-header-admin-else").hide();
        }

        if($(this).scrollTop() > 251){
            $(".yb-header-else-main").show();
        } else {
            $(".yb-header-else-main").hide();
        }
    });

    $("#yb-update-request-status").click(function(e){
        e.preventDefault();
        var link = $(this).attr("href");
        var status = $(this).attr("data-status");
        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'question',
            zindex: 999,
            title: 'Update Item Request Status',
            message: 'Do you realy want to update this request to ' + status.toUpperCase() + '?',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    window.location = link
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });

    // ADMIN TABS

    $(".yb-admin-user-tabs-link ul li a").click(function(e){
        e.preventDefault();
        var target = $(this).attr("href");
        $(this).parent("li").addClass("active").siblings().removeClass("active");
        $(".yb-admin-admin-user-data " + target).addClass("active").siblings().removeClass("active");
        let links =  $(".yb-admin-user-tabs-link ul li a");
        for (let i = 0; i <= links.length; i++){
            if($(links[i]).attr("href") == target){
                $(links[i]).parent("li").addClass("active").siblings().removeClass("active");
            }
        }
    });
});

function capitalize(text){
    return text.replace(text.charAt(0), text.charAt(0).toUpperCase())
}

function setLoadData(container, url){
    setTimeout(function(){
        $("#" + container).load(url, function(){
            $(this).children("span").hide();
            updateMessageScroll();
        }, function(error){
            showErrorMessage("error", error);
        });
    });
}


function showErrorMessage(id, message){
    iziToast.error({
        id: id,
        timeout: 5000,
        title: 'Error',
        message: message,
        position: 'bottomLeft',
        transitionIn: 'bounceInLeft',
        close: false,
    });
}

function showSuccessMessage(id, message){
    iziToast.success({
        id: id,
        timeout: 5000,
        title: 'Success',
        message: message,
        position: 'bottomLeft',
        transitionIn: 'bounceInLeft',
        close: false,
    });
}

function showInfoMessage(id, message){
    iziToast.info({
        id: id,
        timeout: 5000,
        title: 'Info',
        message: message,
        position: 'bottomLeft',
        transitionIn: 'bounceInLeft',
        close: false,
    });
}

function filterSubcategories(input, select){
    var category = input.val()
    var options = select.find("option")
    for(var i = 0; i < options.length; i++){
        if ($(options[i]).attr("category") == category) {
            $(options[i]).show();
        } else {
            $(options[i]).hide();
        }
    }
    select.val(options[0])
}

function previewImage(input, img) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            var ext = $(input).val().split('.').pop().toLowerCase();
            var extVid = $(input).val().split('.').pop();
            if($.inArray(ext, ['gif','png','jpg','jpeg']) > 0) {
                $("#" + img).attr('src', e.target.result);
            }else{
                showErrorMessage("img", "Please, Insert Only Image");
            }
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function multipleImagesPreview(input, placeToInsertImagePreview) {
    placeToInsertImagePreview.empty();
    if (input.files) {
        var filesAmount = input.files.length;
        var images = new Array();
        for (i = 0; i < filesAmount; i++) {
            var reader = new FileReader();
            reader.onload = function(event) {
                var image = $($.parseHTML('<img>')).attr('src', event.target.result).appendTo(placeToInsertImagePreview);
                images.push(image[0].clientHeight)
            }
            reader.readAsDataURL(input.files[i]);
        }
        var max = Math.max.apply(null, images)
    }
}

function showPopup(element){
    $("#" + element).magnificPopup({
        type: 'inline',
        fixedContentPos: false,
        fixedBgPos: true,
        overflowY: 'auto',
        closeBtnInside: true,
        preloader: false,
        midClick: true,
        removalDelay: 300,
        mainClass: 'my-mfp-zoom-in'
    });
}

function randomString(length) {
    var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var result = '';
    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}

jQuery.fn.closePopup = function(){
    $(this).click(function(e){
        e.preventDefault();
        $("body").find(".mfp-close").click();
        $(".yb-qr-preview-container").hide();
        $("#message_images").val(null);
        $("#yb-images-preview").hide();
    });
}


function printDocument(container) {
    
    var contents = document.getElementById(container).innerHTML;
    var frame = document.createElement('iframe');
    
    frame.name = "frame";
    frame.style.position = "absolute";
    frame.style.top = "-1000000px";
    
    document.body.appendChild(frame);
    
    var doc = (frame.contentWindow) ? frame.contentWindow : (frame.contentDocument.document) ? frame.contentDocument.document : frame.contentDocument;
    
    doc.document.open();
    doc.document.write('<html><head><title>Document</title>');
    doc.document.write('</head><body>');
    doc.document.write(contents);
    doc.document.write('</body></html>');
    doc.document.close();

    setTimeout(function () {
        window.frames["frame"].focus();
        window.frames["frame"].print();
        document.body.removeChild(frame);
    }, 500);

    return false;
}

function makeQRCode(c, w, h){
    var qrcode = new QRCode(document.getElementById(c), {
        width : w,
        height : h
    });
    var id = $("#" + c).attr("data-id").toString();
    var user = $("#" + c).attr("data-user");
    var data = id + "-" + user + "-" + randomString(8);
    qrcode.makeCode(data);
}

function makeMoment(time){
    var utc_timestamp = (Date.parse(time)) - (new Date().getTimezoneOffset() * 60 * 1000);
    var hours_check = new Date(utc_timestamp).getHours();

    var post_time = utc_timestamp / 1000;
    var timee =  utc_timestamp;
    var current_time = Math.floor(jQuery.now() / 1000);

    real_time = (current_time - post_time);
    if (real_time < 60) {
        return 'Just Now';
    }else if (real_time >= 60 && real_time < 3600) {
        time_be = moment(timee).fromNow();
        return time_be;
    }else if (real_time >= 3600 && real_time < 86400) {
        time_be = moment(timee).fromNow();
        return time_be;
    }else if (real_time >= 86400 && real_time < 604800) {
        time_b = Math.floor(real_time / (60 * 60 * 24));
        time_be = moment(timee).calendar();
        return time_be;
    }else if (real_time >= 604800 && real_time < 31104000 ) {
        time_be = moment(timee).format('MMMM Do [at] h:mm a');
        return time_be;
    }else{
        time_be = moment(timee).format('DD MMM YYYY [at] h:mm a');
        return time_be;
    }
}

function makeNumber(number){
    return (number >= 1000) ? numeral(number).format('0.0 a') : numeral(number).format('0 a');
}

jQuery.fn.setDate = function(){
    setInterval(() => {
        var time = $(this).attr("data-date");
        $(this).text(makeMoment(time));
        return false;
    }, 100)
}

jQuery.fn.setNumber = function(){
    var number = parseInt($(this).attr("data-number"));
    $(this).text(makeNumber(number).toString().toUpperCase());
}

jQuery.fn.followUser = function(){
    $(this).click(function(e){
        var id = $(this).attr("data-id");
        var form = $("body").find("#yb-user-follow-form-" + id);
        form.submit();
    });
}

jQuery.fn.followCategory = function(){
    $(this).click(function(e){
        e.preventDefault();
        var id = $(this).attr("data-id");
        var form = $("body").find("#yb-user-follow-category-form-" + id);
        form.submit();
    });
}

jQuery.fn.followCategoryEvent = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var url = $(this).attr("action");
        var data = new FormData($(this)[0]);
        var id = $(this).attr("data-id");
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "follow"){
                    showSuccessMessage("success", response.text);
                    $("#yb-user-follow-category-container-" + id).html('<span><i class="icon ion-ios-heart followed"></i></span>');
                    $("#yb-user-follow-category-container").html('<p class="bg-followed"><i class="icon ion-ios-heart"></i> Follow</p>');
                } else if(response.type == "unfollow"){
                    showSuccessMessage("success", response.text);
                    $("#yb-user-follow-category-container-" + id).html('<span><i class="icon ion-ios-heart-outline"></i></span>');
                    $("#yb-user-follow-category-container").html('<p><i class="icon ion-ios-heart-outline"></i> Follow</p>');
                } else {
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.followUserEvent = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var url = $(this).attr("action");
        var user = $(this).attr("data-user");
        var id = $(this).attr("data-id");
        var data = new FormData($(this)[0]);
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "follow"){
                    $("body").find("#yb-user-follow-container-" + id).html('<span><i class="icon ion-person followed"></i></span>');
                    socket.emit("followUser", {"id": id, "user": user, "type": response.type});
                    socket.emit("setNotification", user);
                    $("#yb-user-follow-container-user").html('<a class="yb-edit-user-link" style="background: lightgreen;"><span><i class="icon ion-checkmark" style="color: #FFF;"></i></span> Follow</a>');
                    showSuccessMessage("success", response.text);
                } else if(response.type == "unfollow"){
                    $("body").find("#yb-user-follow-container-" + id).html('<span><i class="icon ion-person-add"></i></span>');
                    $("#yb-user-follow-container-user").html('<a class="yb-edit-user-link" style="background: var(--gray);"><span><i class="icon ion-person-add" style="color: #FFF;"></i></span> Follow</a>');
                    socket.emit("followUser", {"id": id, "user": user, "type": response.type});
                    showSuccessMessage("success", response.text);
                } else {
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.likeItem = function(){
    $(this).click(function(e){
        e.preventDefault();
        var item = $(this).attr("data-item");
        var form = $("body").find("#like_form_" + item);
        form.submit();
    });
}

jQuery.fn.likeItemRequest = function(){
    $(this).click(function(e){
        e.preventDefault();
        var item = $(this).attr("data-item");
        var form = $("body").find("#like_request_form_" + item);
        form.submit();
    });
}


jQuery.fn.likeItemEvent = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var form = $(this);
        var url = $(this).attr("action");
        var item = $(this).attr("item");
        var liker = $(this).attr("data-liker");
        var user = $(this).attr("data-owner");
        var data = new FormData($(this)[0]);
        jQuery.ajax({
            type: "post",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "like"){
                    socket.emit("like", {"item": item, "type": "like", "liker": liker, "user": user});
                    socket.emit("setNotification", user);
                    form.find(".like-" + item).html("<i class='icon ion-ios-heart liked'></i>");
                    showSuccessMessage(randomString(8), response.text)
                } else if (response.type == "dislike"){
                    socket.emit("like", {"item": item, "type": "dislike", "liker": liker, "user": user})
                    form.find(".like-" + item).html("<i class='icon ion-ios-heart-outline'></i>")
                    showSuccessMessage(randomString(8), response.text)
                } else {
                    showErrorMessage(randomString(8), response.text)
                }
            },
            error: function(xhr, t, e){
                showErrorMessage(randomString(8), e);
            }
        });
    });
}

jQuery.fn.likeItemRequestEvent = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var form = $(this);
        var url = $(this).attr("action");
        var item = $(this).attr("item");
        var liker = $(this).attr("data-liker");
        var user = $(this).attr("data-owner");
        var data = new FormData($(this)[0]);
        jQuery.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "like"){
                    socket.emit("rlike", {"item": item, "type": "like", "liker": liker, "user": user})
                    socket.emit("setNotification", user);
                    form.find(".request-like-" + item).html("<i class='icon ion-ios-heart liked'></i>")
                    showSuccessMessage(randomString(8), response.text)
                } else if (response.type == "dislike"){
                    socket.emit("rlike", {"item": item, "type": "dislike", "liker": liker, "user": user})
                    form.find(".request-like-" + item).html("<i class='icon ion-ios-heart-outline'></i>")
                    showSuccessMessage(randomString(8), response.text)
                } else {
                    showErrorMessage(randomString(8), response.text)
                }
            },
            error: function(xhr, t, e){
                showErrorMessage(randomString(8), e);
            }
        });
    });
}

jQuery.fn.favoutiteItem = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var data = new FormData($(this)[0]);
        var url = $(this).attr("action");
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    $("#yb-favourite-item-container").html('<li><p id="yb-favourite-item-else"><span><i class="icon ion-ios-star" style="color: var(--primaryColor);"></i></span></p></li>');
                    $("#yb-menu-items-menu-item").fadeOut();
                    showSuccessMessage("success", response.text)
                } else if(response.type == "unmark"){
                    $("#yb-favourite-item-container").children("li").fadeOut();
                    $("#yb-menu-items-menu-item").fadeOut();
                    showSuccessMessage("unmark", response.text)
                } else {
                    showErrorMessage("error", response.text);
                    $("#yb-menu-items-menu-item").fadeOut();
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.removeFavourite = function(){
    $(this).click(function(e){
        var url = $(this).attr("data-url");
        var id = $(this).attr("data-id");
        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'question',
            zindex: 999,
            title: 'Remove Favourite',
            message: 'Do you realy want to unmark this item ?',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    $.ajax({
                        type:'GET',
                        url: url,
                        data: {},
                        processData: false,
                        contentType: false,
                        success: function(response){
                            if(response.type == "success"){
                                showSuccessMessage("success", response.text);
                                $("#item-favourite-" + id).fadeOut();
                            } else {
                                showErrorMessage("error", response.text);
                            }
                        },
                        error: function(xhr, t, e){
                            showErrorMessage("error", e);
                        }
                    });
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });
}

jQuery.fn.removeLike = function(){
    $(this).click(function(e){
        var url = $(this).attr("data-url");
        var id = $(this).attr("data-id");
        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'question',
            zindex: 999,
            title: 'Dislike Item',
            message: 'Do you realy want to dislike this item ?',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    $.ajax({
                        type:'GET',
                        url: url,
                        data: {},
                        processData: false,
                        contentType: false,
                        success: function(response){
                            if(response.type == "success"){
                                showSuccessMessage("success", response.text);
                                $("#item-like-" + id).fadeOut();
                            } else {
                                showErrorMessage("error", response.text);
                            }
                        },
                        error: function(xhr, t, e){
                            showErrorMessage("error", e);
                        }
                    });
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });
}

jQuery.fn.postItemComment = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var data = new FormData($(this)[0])
        var url = $(this).attr("action");
        var comments = $(this).attr("data-url");
        var item = $(this).attr("data-item");
        var form = $(this);
        var from = $(this).attr("data-from");
        var user = $(this).attr("data-user");
        $.ajax({
            type:'POST',
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    socket.emit("comment", {"url": comments, "item": item, "from": from });
                    socket.emit("setNotification", user);
                    showSuccessMessage("success", response.text);
                    $(".mfp-close").click();
                } else {
                    showErrorMessage("error", response.text);
                }
                $("#new_comment")[0].reset();
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.deleteComment = function(){
    $(this).click(function(e){
        e.preventDefault();
        var comment = $(this).attr("data-comment");
        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'question',
            zindex: 999,
            title: 'Delete Comment',
            message: 'Do you realy want to delete this comment ?',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    $("body").find("#delete-comment-form-" + comment).submit();
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });
}

jQuery.fn.deleteCommentEvent = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var url = $(this).attr("action");
        var item = $(this).attr("data-item");
        var comments = $(this).attr("data-url");
        var form = new FormData($(this)[0])
        $.ajax({
            type: "POST",
            url : url,
            data: form,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    socket.emit("comment", {"url": comments, "item": item, "from": "delete" });
                    showSuccessMessage("success", response.text);
                }else{
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.deleteItemImage = function(){
    $(this).click(function(){
        var _this = $(this)
        var url = _this.attr("data-url");
        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'question',
            zindex: 999,
            title: 'Delete Image',
            message: 'Do you realy want to delete this image ?',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    $.ajax({
                        type:'GET',
                        url: url,
                        data:{},
                        success: function(response){
                            if(response.type == "success"){
                                showSuccessMessage("success", response.text)
                                _this.parent("li").fadeOut();
                            } else {
                                showErrorMessage("error", response.text)
                            }
                        }
                    });
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });
}

jQuery.fn.borrowItemUser = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var form = new FormData($(this)[0]);
        var url = $(this).attr("action");
        var user = $(this).attr("data-user");

        for (instance in CKEDITOR.instances) {
            CKEDITOR.instances[instance].updateElement();
        }

        $.ajax({
            type:"POST",
            url: url,
            data: form,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    showSuccessMessage("success", response.text);
                    socket.emit("setNotification", user);
                    $(".mfp-close").click();
                } else if(response.type == "info") {
                    showInfoMessage("info", response.text);
                }else{
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}


jQuery.fn.updateBorrowItemUser = function(){
    $(this).submit(function(e){
        e.preventDefault();

        var form = new FormData($(this)[0]);
        var _this = $(this);

        var borrow = _this.attr("data-borrow");
        var item = _this.attr("data-item");
        var url = _this.attr("data-url");
        var receiver = _this.attr("data-receiver");
        var sender = _this.attr("data-sender");
        var path = _this.attr("data-path");
        var action = _this.attr("action");

        for (instance in CKEDITOR.instances) {
            CKEDITOR.instances[instance].updateElement();
        }

        $.ajax({
            type:"POST",
            url: action,
            data: form,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    showSuccessMessage("success", response.text);
                    socket.emit("setNotification", receiver);
                    var message = {
                        "item": item,
                        "borrow": borrow,
                        "receiver": receiver,
                        "sender": sender,
                        "message": response.text,
                        "url": url,
                        "path": path,
                        "type": "message"
                    }
                    socket.emit("messageSent", message);
                    $(".mfp-close").click();
                } else if(response.type == "info") {
                    showInfoMessage("info", response.text);
                }else{
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.updateBorrowItemUserStatus = function(){
    $(this).click(function(e){
        e.preventDefault();

        var _this = $(this);
        var borrow = _this.attr("data-borrow");
        var item = _this.attr("data-item");
        var url = _this.attr("data-url");
        var receiver = _this.attr("data-receiver");
        var sender = _this.attr("data-sender");
        var path = _this.attr("data-path");
        var action = _this.attr("href");
        var status = _this.attr("data-status");

        iziToast.question({
            timeout: 10000,
            close: false,
            overlay: true,
            toastOnce: true,
            id: 'accept',
            zindex: 999,
            title: 'Update Borrow Item User Status',
            message: 'Do you really want to update the status to <b>' + status.toUpperCase() + ' ?</b>',
            position: 'center',
            buttons: [
                ['<button><b>YES</b></button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    socket.emit("setNotification", receiver);
                    var message = {
                        "item": item,
                        "borrow": borrow,
                        "receiver": receiver,
                        "sender": sender,
                        "message": "has updated borrow item status to " + status.toUpperCase() + " !!!",
                        "url": url,
                        "path": path,
                        "type": "status"
                    }
                    window.location = action;
                    socket.emit("messageSent", message);                     
                }, true],
                ['<button>NO</button>', function (instance, toast) {
                    instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                    showInfoMessage("info", "Operation Cancelled !!!");
                }],
            ],
            onClosing: function(instance, toast, closedBy){},
            onClosed: function(instance, toast, closedBy){
                showInfoMessage("info", "Operation Cancelled !!!");
            }
        });
    });
}

jQuery.fn.messageText = function(){
    var _this = $(this);
    var borrow = _this.attr("data-borrow");
    var item = _this.attr("data-item");
    var url = _this.attr("data-url");
    var receiver = _this.attr("data-receiver");
    var sender = _this.attr("data-sender");
    var path = _this.attr("data-path");
    _this.find("textarea").keyup(function(e){
        var value = $(this).val();
        if (value != ""){
            _this.find("button").removeAttr("disabled").children("i").addClass("yb-btn-color");
        } else {
            _this.find("button").attr("disabled", "disabled").children("i").removeClass("yb-btn-color");
        }
        emitTypeTextSocket(value, _this);
        if (e.keyCode === 13) _this.find("button[type=submit]").click();
    });
    _this.find("input[type=file]").change(function(){
        var value = $(this).val();
        if (value != null){
            _this.find("button[type=submit]").removeAttr("disabled").children("i").addClass("yb-btn-color");
        } else {
            _this.find("button[type=submit]").attr("disabled", "disabled").children("i").removeClass("yb-btn-color");
        }
        emitTypeTextSocket(value, _this);
    });
    _this.find("button[type=button]").click(function(e){
        e.preventDefault();
        emitTypeTextSocket("", _this);
    });
    _this.submit(function(e){
        e.preventDefault();
        var data = new FormData(_this[0]);
        var action = _this.attr("action");
        $.ajax({
            type: "POST",
            url: action,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                var message = {
                    "item": item,
                    "borrow": borrow,
                    "receiver": receiver,
                    "sender": sender,
                    "message": response.text,
                    "url": url,
                    "path": path,
                    "type": "message"
                }
                socket.emit("messageSent", message);
                _this.children("textarea").val("");
                _this.children("input[type=file]").val(null);
                $("#yb-images-preview").hide();
                $(".mfp-close").click();
                emitTypeTextSocket("", _this);
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

function emitTypeTextSocket(message, data){
    var data = {
        "item": data.attr("data-item"),
        "borrow": data.attr("data-borrow"),
        "receiver": data.attr("data-receiver"),
        "sender": data.attr("data-sender"),
        "message": message,
    }
    socket.emit("textType", data);
}

jQuery.fn.suggestItemRequest = function(){
    $(this).submit(function(e){
        e.preventDefault();
        var action = $(this).attr("action");
        var owner = $(this).attr("data-owner");
        var request = $(this).attr("data-request");
        var user = $(this).attr("data-user");
        var url = $(this).attr("data-url");
        var from = $(this).attr("data-from");
        var data = new FormData($(this)[0]);

        $.ajax({
            type: "POST",
            url: action,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    showSuccessMessage("success", response.text);
                    var suggestion = {
                        "owner": owner,
                        "request": request,
                        "user": user,
                        "url": url,
                        "from": from
                    }
                    socket.emit("suggestion", suggestion);
                    socket.emit("setNotification", owner);
                    console.log(suggestion);
                    $(".mfp-close").click();
                } else {
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.updateRequestSuggestionStatus = function(){
    
    let _this = $(this);
    let url = _this.attr("data-url");
    let owner = _this.attr("data-owner");
    let user = _this.attr("data-user");
    let status = ["accepted", "rejected", "removed"]

    _this.find("a").click(function(e){
        e.preventDefault();
        if($(this).hasClass("yb-suggestion-status")){
            let action = $(this).attr("href");
            let _status = $(this).attr("data-status");
            iziToast.question({
                timeout: 10000,
                close: false,
                overlay: true,
                toastOnce: true,
                id: 'question',
                zindex: 999,
                title: 'Update Item Suggestion Status',
                message: 'Do you realy want to update this Item Suggestion to ' + status[_status - 1].toUpperCase() + ' ?',
                position: 'center',
                buttons: [
                    ['<button><b>YES</b></button>', function (instance, toast) {
                        instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                        $.ajax({
                            type: "GET",
                            url: action,
                            data: {"type":"check"},
                            success: function(response){
                                if(response.type == "success"){
                                    socket.emit("updateSuggestion", {
                                        "owner":owner,
                                        "user":user,
                                        "url":url,
                                        "status":status[parseInt(_status) - 1].toUpperCase(),
                                        "about":"suggestion"
                                    });
                                    socket.emit("setNotification", owner);
                                    showSuccessMessage("success", response.text);
                                } else if (response.type == "check" && parseInt(_status) == 1){
                                    iziToast.question({
                                        timeout: 10000,
                                        close: false,
                                        overlay: true,
                                        toastOnce: true,
                                        id: 'accept',
                                        zindex: 999,
                                        title: 'Accept Item Request Suggestion',
                                        message: 'Quantity available is <b>' + response.text + ' items.</b> Do you want to borrow them ?',
                                        position: 'center',
                                        buttons: [
                                            ['<button><b>YES</b></button>', function (instance, toast) {
                                                instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                                                $.ajax({
                                                    type: "GET",
                                                    url: action,
                                                    data: {"type":"update"},
                                                    success: function(response){
                                                        if(response.type == "success"){
                                                            socket.emit("updateSuggestion", {
                                                                "owner":owner,
                                                                "user":user,
                                                                "url":url,
                                                                "status":status[parseInt(_status)].toUpperCase(),
                                                                "about":"suggestion-status"
                                                            });
                                                            socket.emit("setNotification", owner);
                                                            showSuccessMessage("success", response.text);
                                                            showSuccessMessage("borrow", response.borrow);
                                                        } else{
                                                            showErrorMessage("error", response.text)
                                                        }
                                                    },
                                                    error: function(xhr, t, e){
                                                        showErrorMessage("error", e);
                                                    }
                                                });
                                            }, true],
                                            ['<button>NO</button>', function (instance, toast) {
                                                instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                                                showInfoMessage("info", "Operation Cancelled !!!");
                                            }],
                                        ],
                                        onClosing: function(instance, toast, closedBy){},
                                        onClosed: function(instance, toast, closedBy){
                                            showInfoMessage("info", "Operation Cancelled !!!");
                                        }
                                    });
                                } else{
                                    showErrorMessage("error", response.text)
                                }
                            },
                            error: function(xhr, t, e){
                                showErrorMessage("error", e);
                            }
                        });
                    }, true],
                    ['<button>NO</button>', function (instance, toast) {
                        instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                        showInfoMessage("info", "Operation Cancelled !!!");
                    }],
                ],
                onClosing: function(instance, toast, closedBy){},
                onClosed: function(instance, toast, closedBy){
                    showInfoMessage("info", "Operation Cancelled !!!");
                }
            });
        }
    });
}

jQuery.fn.submitReport = function(){
    $(this).submit(function(e){
        e.preventDefault();
        let data = new FormData($(this)[0]);
        let url = $(this).attr("action");
        $.ajax({
            type: "POST",
            url: url,
            data: data,
            processData: false,
            contentType: false,
            success: function(response){
                if(response.type == "success"){
                    showSuccessMessage("success", response.text);
                    $(".mfp-close").click();
                } else {
                    showErrorMessage("error", response.text);
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });
}

jQuery.fn.changeItemPrice = function(input, value, def){
    $(this).change(function(){
        var per = ["Hour", "Day", "Week", "Month", "Year"]
        var price;
        $("#" + input).val(parseFloat(price))
    });
}

jQuery.fn.showMenu = function (){
    let id = $(this).attr("data-id");
    $(window).click(function(e){
        $("#yb-menu-items-" + id).fadeOut();
    });
    $("#yb-menu-items-" + id).click(function (ev) {
        ev.stopPropagation();
    });
    $(this).click(function(ev){
        ev.stopPropagation();
        ev.preventDefault();
        $("#yb-menu-items-" + id).fadeIn();
    });
}

jQuery.fn.activateList = function(){
    let id = $(this).attr("data-id");
    let list_items = $(this).find("li")
    for(var i = 0; i <= list_items.length; i++){
        if($(list_items[i]).attr("data-id") == id){
            $(list_items[i]).addClass("active").siblings().removeClass("active");
        }
    }
}

jQuery.fn.openImageGallery = function(){
    $(this).click(function(e){
        e.preventDefault();
        let id = $(this).attr("data-id");
        let items = $("#yb-image-gallery-" + id);
        let list = items.find("a");
        let first = list.get(0);
        first.click();
    });
}

jQuery.fn.imagesGallery = function(){
    $(this).magnificPopup({
        delegate: 'a',
        type: 'image',
        closeOnContentClick: false,
        closeBtnInside: false,
        mainClass: 'mfp-with-zoom mfp-img-mobile',
        image: {
            verticalFit: true,
            titleSrc: function(item) {
                return item.el.attr('title');
            }
        },
        gallery: {
            enabled: true
        }
    });
}

jQuery.fn.selectItem = function(){
    $(this).click(function(e){
        e.preventDefault();
        let id = $(this).attr("data-id");
        $(this).children("span").html('<i class="icon ion-android-checkbox-outline"></i>').parent("li").siblings().children("span").html('<i class="icon ion-android-checkbox-outline-blank"></i>');
        $("body").find("#suggestion_item_id").val(id);
    });
}

jQuery.fn.activeImageSuggestion = function(){
    let item = $(this).find("li");
    let id = $(this).attr("data-id");
    item.click(function(e){
        e.preventDefault();
        let image = $(this).attr("data-image");
        $(this).addClass("active").siblings().removeClass("active");
        $("#yb-suggestion-image-" + id).attr("src", image);
    });
}

jQuery.fn.searchAdminUser = function(){

    let form = $(this);
    let textInput = form.find("#admin_search_admin_query");
    let userInput = form.find("#admin_user_user_id");
    let container = form.find(".yb-users-suggestion");
    let list = container.find(".yb-suggestion-list ul");
    let spinner = container.find("span");
    let collapse = container.find("a");
    let button = form.find("button[type=submit]");
    let close = form.find("button[type=button]");
    let url = form.attr("data-url");

    close.closePopup();

    button.click(function(e){
        if(userInput.val() == null || userInput.val() == ""){
            e.preventDefault();
            showErrorMessage("error", "Please Select A User !!!")
        } else {
            from.submit();
        } 
    });

    textInput.focus(function(){
        container.show();
    });

    textInput.keyup(function(){

        let query = textInput.val();
        $.ajax({
            type: "GET",
            url: url,
            data:{"query" : query},
            success: function(response){
                list.empty();
                if(response.length > 0){
                    spinner.hide();
                    response.forEach(function(user){
                        let item = $(adminUserTemplate(user));
                        item.click(function(){
                            userInput.val(user.id);
                            textInput.val(user.name);
                            list.empty();
                            spinner.show();
                            container.hide();
                        });
                        list.append(item);
                    });
                }
            },
            error: function(xhr, t, e){
                showErrorMessage("error", e);
            }
        });
    });

    collapse.click(function(e){
        e.preventDefault();
        container.hide();
    });

    close.click(function(e){
        reset();
    });

    function reset(){
        list.empty();
        spinner.show();
        container.hide();
        userInput.val("");
        textInput.val("");
    }
}

jQuery.fn.ybLiveSeacrh = function(){

    let form = $(this);
    let url = $(this).attr("action");
    let input = form.find("input");
    let spinner = $("#yb-search-form-spinner");
    let results = $("#yb-search-result");
    let dissallowed = [13, 38, 40];
    let index = -1;

    input.keyup(function(e){
        spinner.show();
        results.show().focus();
        let query = $(this).val();
        let active = results.find(".active");
        let responses = results.find(".yb-search-data");
        let resultsHeight = results.height();
        if(e.keyCode === 13){
            e.preventDefault();
            if(active.length > 0){window.location = active.attr("data-url")} 
            else { window.location = url + "?q=" + query}
        }
        if(e.keyCode === 38){
            e.preventDefault();
            if(responses.length > 0){
                if(index <= 0) {index = responses.length; resultsHeight = results.height(); results.scrollTop(0)}
                if(index >= responses.length){results.scrollTop(results.height())}
                index--;
                if(index <= 0) {}
                $(responses[index]).addClass("active").siblings().removeClass("active");
                input.val($(responses[index]).attr("data-name"));
                if(index > 3 && index < responses.length - 3) { resultsHeight += 100; results.scrollTop(resultsHeight) }
                if(index < 3) { resultsHeight = results.height(); results.scrollTop(0) }
            }
        }
        if(e.keyCode === 40){
            e.preventDefault();
            if(responses.length > 0){
                index++;
                if(index == 0) {resultsHeight = results.height(); results.scrollTop(0)}
                $(responses[index]).addClass("active").siblings().removeClass("active");
                input.val($(responses[index]).attr("data-name"));
                if(index > 3) { resultsHeight -= 100; results.scrollTop(resultsHeight) }
                if(index >= responses.length - 1) {index = -1; results.scrollTop(results.height())}
            }  
        }
        if(query == "" || query == null) {spinner.hide(); results.hide()}
        if(!dissallowed.includes(e.keyCode)){
            $.ajax({
                type:"GET",
                url: url + ".json",
                data: {"q":query},
                success: function(response){
                    let data = response.results;
                    if(data.length > 0){
                        results.empty();
                        index = -1;
                        data.forEach((dt) => {
                            let template = $(resultSearchTemplate(dt.data, dt.type));
                            template.click(function(){
                                if(window.location.href.toString().includes("/admin/")){
                                    window.open($(this).attr("data-url"), "_blank");
                                } else {window.location = $(this).attr("data-url")}
                            }); 
                            template.hover(function(){
                                let resps = results.find(".yb-search-data");
                                $(this).addClass("active").siblings().removeClass("active");
                                input.val($(this).attr("data-name"));
                                index = data.indexOf(dt) + 1;
                            });
                            results.append(template).focus();
                        });
                    } else {
                        results.html('<p class="yb-error">NO RESULT FOUND</p>');
                    }
                },
                error: function(xhr, t, e){
                    showErrorMessage("error", e);
                }
            });
        }
    });
}

function resultSearchTemplate(data, type){
    if(type == "user"){
        return `
            <div class="yb-search-data" data-url="${data.url_html}" data-name="${data.name}">
                <div class="yb-search-data-image">
                    <img src="${data.image}">
                </div>
                <div class="yb-search-data-description">
                    <h4>${data.name}</h4>
                    <p class="yb-location"><i class="icon ion-ios-location-outline"></i> ${data.town}, ${data.country}</p>
                    <p class="yb-date">@${data.username} - ${makeMoment(data.created_at)}</p>
                </div>
            </div>
        `;
    } else if(type == "item"){
        return `
            <div class="yb-search-data" data-url="${data.url}" data-name="${data.name}">
                <div class="yb-search-data-image">
                    <img src="${data.image}">
                </div>
                <div class="yb-search-data-description">
                    <h4>${data.name}</h4>
                    <p class="yb-price"><i class="icon ion-ios-pricetags-outline"></i> ${makeNumber(data.price).toString().toUpperCase()} ${data.currency} / ${data.per}</p>
                    <p class="yb-location"><i class="icon ion-ios-location-outline"></i> ${data.location} - ${data.category}, ${data.subcategory}</p>
                    <p class="yb-date">By ${data.user} - ${makeMoment(data.created_at)}</p>
                </div>
            </div>
        `;
    } else if(type == "request"){
        return `
            <div class="yb-search-data" data-url="${data.url}" data-name="${data.name}">
                <div class="yb-search-data-image">
                    <img src="${data.image}">
                </div>
                <div class="yb-search-data-description">
                    <h4>${data.name}</h4>
                    <p class="yb-price"><i class="icon ion-ios-pricetags-outline"></i> ${makeNumber(data.min_price).toString().toUpperCase()} - ${makeNumber(data.max_price).toString().toUpperCase()} ${data.currency} / ${data.per}</p>
                    <p class="yb-location"><i class="icon ion-ios-location-outline"></i> ${data.location} - ${data.category}, ${data.subcategory}</p>
                    <p class="yb-date">By ${data.user} - ${makeMoment(data.created_at)}</p>
                </div>
            </div>
        `;
    }
}

function adminUserTemplate(user){
    return `<li data-id="${user.id}">
                <div class="yb-image">
                    <img src="${user.image}">
                </div>
                <div class="yb-about">
                    <h3>${user.name}</h3>
                    <p class="yb-location"><i class="icon ion-ios-location-outline"></i> ${user.town}, ${user.country}</p>
                    <p class="yb-email"><i class="icon ion-ios-email-outline"></i> ${user.email}</p>
                </div>
            </li>`;
}

function updateMessageScroll(){
    let message_list = $("#yb-borrow-messages-container");
    message_list.scrollTop = message_list.scrollHeight;
    $("#yb-borrow-messages-container").animate({ scrollTop: 100000000}, 1000);
}

function getUserCurrentLocation(lat, long, addr, where){

    if(!navigator.geolocation){
        return showErrorMessage('error_geolocation', 'Geolocation not supported by your browser');
    }
    navigator.geolocation.getCurrentPosition(function(position){

        var geocoder = new google.maps.Geocoder();
        var location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
        
        geocoder.geocode({'latLng': location}, function(results, status){

            if (status == google.maps.GeocoderStatus.OK) {

                var latitude =  position.coords.latitude;
                var longitude = position.coords.longitude;
                var address = results[0].formatted_address;

                var length = results[0].address_components.length
                var country = results[0].address_components[length - 1]
                var town = results[0].address_components[length - 3]

                if(where == "s"){
                    document.getElementById(lat).value = town.long_name;
                    document.getElementById(long).value = country.short_name;
                } else {
                    document.getElementById(lat).value = latitude;
                    document.getElementById(long).value = longitude;
                    document.getElementById(addr).value = address;
                }

            } else {
                showErrorMessage("locate_user", status);
            }
        });
    }, function(){
        showErrorMessage("locate_user", 'Unable to fetch location');
    });
}

function ConvertItemPrice(price, to, per){
    this.price = price
    this.to = to
    this.per = per
}

ConvertItemPrice.prototype.hour = function() {
    switch(this.to){
        case this.per[0]:
            return this.price
        case this.per[1]:
            return this.price * 24
        case this.per[2]:
            return this.price * 7 * 24
        case this.per[3]:
            return this.price * 30 * 24
        case this.per[4]:
            return this.price * 12 * 30 * 24
        default:
            return 0
    }
};

ConvertItemPrice.prototype.day = function() {
    switch(this.to){
        case this.per[0]:
            return this.price / 24
        case this.per[1]:
            return this.price
        case this.per[2]:
            return this.price * 7
        case this.per[3]:
            return this.price * 30
        case this.per[4]:
            return this.price * 12 * 30
        default:
            return 0
    }
};

ConvertItemPrice.prototype.week = function(){
    switch(this.to){
        case this.per[0]:
            return this.price / (7 * 24)
        case this.per[1]:
            return this.price / 7
        case this.per[2]:
            return this.price
        case this.per[3]:
            return this.price * (30 / 7)
        case this.per[4]:
            return this.price * ((12 * 30) / 7)
        default:
            return 0
    }
};

ConvertItemPrice.prototype.month = function(){
    switch(this.to){
        case this.per[0]:
            return this.price / (30 * 24)
        case this.per[1]:
            return this.price / 30
        case this.per[2]:
            return this.price / (30 / 7)
        case this.per[3]:
            return this.price
        case this.per[4]:
            return this.price * 12
        default:
            return 0
    }
};

ConvertItemPrice.prototype.year = function(){
    switch(this.to){
        case this.per[0]:
            this.price / (12 * 30 * 24)
        case this.per[1]:
            return this.price / (12 * 30)
        case this.per[2]:
            return this.price / ((12 * 30) / 7)
        case this.per[3]:
            return this.price / 12
        case this.per[4]:
            return this.price
        default:
            return 0
    }
};