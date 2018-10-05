$ ->
  	if $('.pagination').length && $('#yb-item-request-list').length
    	$(window).scroll ->
      		url = $('.pagination .next_page').attr('href')
      		if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        		$('.pagination').text("Loading more items...")
        		$.getScript(url)
    	$(window).scroll()