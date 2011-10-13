if(typeof jQuery != 'undefined') {
	$(function() {
		$('body').addClass('jsenabled');
		// cache selectors
		var main = $('#main');
		if(!$.support.opacity) {
			$('.features th:last-child, .features td:last-child, .features tr:last-child, .features tbody:last-child, .utility a:last-child, .widget div li:last-child','#content').addClass('last');
		}
		// search field default value
		function hasPlaceholderSupport() {
			var input = document.createElement('input');
			return ('placeholder' in input);
		}
		if(hasPlaceholderSupport() == false) {
			var searchField = $('#s_inp','#header');
			var labelText = searchField.prev().text();
			searchField
				.val(labelText)
				.addClass('default')
				.focus(function() {
					if($(this).val() == labelText) {
						$(this).val('').removeClass('default');
					}
				})
				.blur(function() {
					if($(this).val() == '') {$(this).val(labelText).addClass('default')}
				})
				.prev()
					.hide();
		}
		var utilSearch = $('.utility #us_input','footer');
		var valText = utilSearch.attr('title');
		utilSearch
			.val(valText)
			.addClass('default')
			.focus(function() {
				if($(this).val() == valText) {
					$(this).val('').removeClass('default');
				}
			})
			.blur(function() {
				if($(this).val() == '') {$(this).val(valText).addClass('default')}
			});
		// end search field default value
		// side nav accordion functionality
		$('#sub li > span').click(function() {
			var that = $(this);
			if(that.parent().hasClass('active')) {
				that.next().slideUp(function() {
					that.parent().removeClass('active');
				});
			}
			else {
				that.next().slideDown().end().parent().addClass('active');
			}
		});
		$('#sub li').find('.current').parent().show().closest('li').addClass('active');
		// end side nav accordion functionality
		$('.features thead th:first-child').addClass('title').append($('.features caption').text()).closest('table').children('caption').remove();
		$('.utility')
			.contents()
				.wrapAll($('<div>', {'class': 'u_wrapper'}))
				.end()
			.find('form')
				.after($('<div>', {'class': 'border'}))
				.end()
			.find('input[type=image]')
				.click(function(e) {
					e.preventDefault();
					$(this).closest('form').addClass('active');
				});
		var inside = false;
		$('.utility form').hover(function(){ 
		    inside=true; 
			}, function(){ 
		    inside=false; 
		});
		$('body').mouseup(function(){ 
	    if(!inside) {
	    	$('.utility form.active').removeClass('active');
	    }
		});
		if(jQuery().tooltip) {
			$('.utility a img, .utility input[type=image]').tooltip({
				showURL: false,
				track: true,
				top: -8
			});
		}
		$('.post + .pagination',main).clone().insertBefore(main);
	});
}
