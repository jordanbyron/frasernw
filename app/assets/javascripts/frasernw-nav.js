!function( $ ){

  "use strict"

  var nav_transition = function(method, startEvent, completeEvent) 
  {
    var complete = function() {
      $('#left-nav').trigger(completeEvent)
    }
    
    $('#left-nav')
      .trigger(startEvent)
      [method]('pushed')
    
    $.support.transition ?
      $('#left-nav').one($.support.transition.end, complete) :
      complete()
  }

  var nav_push = function() {
    $('#left-nav').each(function () {
      nav_transition('addClass', 'show', 'push')
    })
  }

  var nav_pop = function() {
   $('#left-nav').each(function () {
      nav_transition('removeClass', 'hide', 'pop')
    })
  }

  $(function() {
    $('body').on('click.nav_panel.data-api', '[data-toggle=push]', function ( e ) {
      nav_push()
    })
    
    $('body').on('click.nav_panel.data-api', '[data-toggle=pop]', function ( e ) {
      nav_pop()
    })
  })
  
  //fix up navigation based off where we loaded site
  $(document).ready(function()
  {
    var url = History.getState().url;
    
    var found = false;
                    
    //highlight specialization on root nav
    $('#root > ul > li').each( function () {
      var nav_link = $(this);
      var link = $('a:first', nav_link);
      var link_url = link.attr("href");
      if (url.indexOf( link_url, url.length - link_url.length ) !== -1)
      {
        nav_link.addClass('active');
        return false;
      }
    });
  });

}( window.jQuery )