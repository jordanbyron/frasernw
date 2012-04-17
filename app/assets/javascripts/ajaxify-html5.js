// https://gist.github.com/854622
(function(window,undefined){
	
	// Prepare our Variables
	var
		History = window.History,
		$ = window.jQuery,
		document = window.document;

	// Check to see if History.js is enabled for our Browser
	if ( !History.enabled ) {
		return false;
	}

	// Wait for Document
	$(function(){
		// Prepare Variables
		var
			/* Application Specific Variables */
			$content = $('#container').filter(':first'),
			contentNode = $content.get(0),
			$menu = $('#left-nav').filter(':first'),
      fadeSpeed = 75,
			/* Application Generic Variables */
			$body = $(document.body),
			rootUrl = History.getRootUrl(),
			scrollOptions = {
				duration: 800,
				easing:'swing'
			},
    form = false;
		
		// Ensure Content
		if ( $content.length === 0 ) {
			$content = $body;
		}
		
		// Internal Helper
		$.expr[':'].internal = function(obj, index, meta, stack){
			// Prepare
			var
				$this = $(obj),
				url = $this.attr('href')||'',
				isInternalLink;
			
			// Check link
			isInternalLink = url.substring(0,rootUrl.length) === rootUrl || url.indexOf(':') === -1;
			
			// Ignore or Keep
			return isInternalLink;
		};
		
		// HTML Helper
		var documentHtml = function(html){
			// Prepare
      var result = String(html)
      .replace(/<\!DOCTYPE[^>]*>/i, '')
      .replace(/<(html|head|body|title|script)([\s\>])/gi,'<div class="document-$1"$2')
      .replace(/<\/(html|head|body|title|script)\>/gi,'</div>')
      ;
        
			// Return
			return result;
		};
		
		// Ajaxify Helper
		$.fn.ajaxify = function(){
			// Prepare
			var $this = $(this);
			
			// Ajaxify
			$this.find('a.ajax:internal').click(function(event){
				// Prepare
        form = null;       
				var
					$this = $(this),
					url = $this.attr('href'),
					title = $this.attr('title')||null;
				
				// Continue as normal for cmd clicks etc
				if ( event.which == 2 || event.metaKey ) { return true; }
				
				// Ajaxify this link                     
        History.pushState(null,title,url);
				event.preventDefault();
				return true;
			});
			
			
			// Ajaxify forms
			$this.find('form.ajax').submit(function(event){
				// Prepare
        form = $(this)
				var
					$this = $(this),
					url = $this.attr('action'),
					title = null;
				
				// Continue as normal for cmd clicks etc
				if ( event.which == 2 || event.metaKey ) { return true; }
				
        // Ajaxify this link
        History.pushState(null,title,url);
				event.preventDefault();
				return true;
			});
			
			// Chain
			return $this;
		};
		
		// Ajaxify our Internal Links
		$body.ajaxify();
		
		// Hook into State Changes
		$(window).bind('statechange',function(){
			// Prepare Variables
			var
				State = History.getState(),
				url = State.url,
				relativeUrl = url.replace(rootUrl,'');

			// Set Loading
			$body.addClass('loading');

			// Start Fade Out
			// Animating to opacity to 0 still keeps the element's height intact
			// Which prevents that annoying pop bang issue when loading in new content
      $('.tt').tooltip('hide');
			$content.animate({opacity:0},fadeSpeed);
			
			// Ajax Request the Traditional Page
			$.ajax({
				url: url,
        type: form != null ? 'POST' : 'GET',
        data: form != null ? form.serialize() : null,
        beforeSend: function(xhr){
          xhr.setRequestHeader('X-PJAX', 'true');
        },
				success: function(data, textStatus, jqXHR){
					// Prepare
					var
						$data = $(documentHtml(data)),
						$dataContent = $data.find('.document-body:first'),
             $menuChildren, contentHtml, $scripts;
             
          // Fetch the scripts
          $scripts = $dataContent.find('.document-script');
          if ( $scripts.length ) {
             $scripts.detach();
          }

					// Fetch the content
					contentHtml = $dataContent.html()||$data.html();
					if ( !contentHtml ) {
						document.location.href = url;
						return false;
					}
					
					// Update the menu
					$menuChildren = $menu.find('.nav_panel > ul > li, #root > ul > li');
					$menuChildren.filter('.active').removeClass('active');
					$menuChildren = $menuChildren.has('a[href="'+relativeUrl+'"],a[href="/'+relativeUrl+'"],a[href="'+url+'"]');
					if ( $menuChildren.length >= 1 ) { $menuChildren.addClass('active'); }

					// Update the content
					$content.stop(true,true);
					$content.html(contentHtml).ajaxify().css({opacity: 0, visibility: "visible"}).animate({opacity:1.0},fadeSpeed);

					// Update the title
					document.title = $data.find('.document-title:first').text();
					try {
						document.getElementsByTagName('title')[0].innerHTML = document.title.replace('<','&lt;').replace('>','&gt;').replace(' & ',' &amp; ');
					}
					catch ( Exception ) { }

					// Add the scripts
					$scripts.each(function(){
						var $script = $(this), scriptText = $script.text(), scriptNode = document.createElement('script');
						scriptNode.appendChild(document.createTextNode(scriptText));
						contentNode.appendChild(scriptNode);
					});

					// Complete the change
					if ( $body.ScrollTo||false ) { $body.ScrollTo(scrollOptions); } /* http://balupton.com/projects/jquery-scrollto */
					$body.removeClass('loading');
	
					// Inform Google Analytics of the change
					if ( typeof window.pageTracker !== 'undefined' ) {
						window.pageTracker._trackPageview(relativeUrl);
					}

					// Inform ReInvigorate of a state change
					if ( typeof window.reinvigorate !== 'undefined' && typeof window.reinvigorate.ajax_track !== 'undefined' ) {
						reinvigorate.ajax_track(url);
						// ^ we use the full url here as that is what reinvigorate supports
					}
				},
				error: function(jqXHR, textStatus, errorThrown){
					document.location.href = url;
					return false;
				}
			}); // end ajax

		}); // end onStateChange

	}); // end onDomLoad

})(window); // end closure