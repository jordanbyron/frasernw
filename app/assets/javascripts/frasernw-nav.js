!function( $ ){

  "use strict"

  var nav_transition = function ( target, resize, method, startEvent, completeEvent ) 
  {
    var that = $(target)
    , complete = function () {
      that.trigger(completeEvent)
    }
    
    $(target)
      .trigger(startEvent)
      [method]('pushed')
    
    $('#left-nav').height( $(resize)[0].scrollHeight )
    
    $.support.transition && $(target).hasClass('nav_panel') ?
      $(target).one($.support.transition.end, complete) :
      complete()
  }

  var nav_push = function ( target, resize ) {
    $(target).each(function () {
      nav_transition(target, resize, 'addClass', 'show', 'push')
    })
  }

  var nav_pop = function ( target, resize ) {
    $(target).each(function () {
      nav_transition(target, resize, 'removeClass', 'hide', 'pop')
    })
  }

  $(function () {
    $('body').on('click.nav_panel.data-api', '[data-toggle=push]', function ( e ) {
      var $this = $(this)
        , target = $this.attr('data-target') || e.preventDefault() || $this.attr('href')
        , resize = target
      nav_push(target, resize)
    })
    
    $('body').on('click.nav_panel.data-api', '[data-toggle=pop]', function ( e ) {
      var $this = $(this)
        , target = $this.attr('data-target') || e.preventDefault() || $this.attr('href')
        , resize = $this.attr('data-parent') || e.preventDefault()
      nav_pop(target, resize)
    })
  })
  
  //fix up navigation based off where we loaded site
  $(document).ready(function()
  {
    var url = History.getState().url;
    
    var found = false;
    
    //check root, push any panel we have selected (e.g. we started on a specialty)
    $('#root > ul > li').each( function () {
      var nav_link = $(this);
      var link = $('a:first', nav_link);
      var link_url = link.attr("href");
      if (url.indexOf( link_url, url.length - link_url.length ) !== -1)
      {
        //highlight link on the root nav
        nav_link.addClass('active');
        //push the panel for the specialization
        var child_panel = $(link.attr("data-target"));
        child_panel.addClass('pushed');
        found = true;
        return false;
      }
    });
    
    if (found)
    {
      return true;
    }
    
    //check all panel links, pushing and activating if any are selected
    $('.nav_panel').each( function() {
      var nav_panel = $(this);
      var parent_panel = $('a.pop:first', nav_panel).attr("data-parent");
      var found = false;
      $('li', nav_panel).each( function () {
        var nav_link = $(this);
        var link = $('a:first', nav_link);
        var link_url = link.attr("href");
        if (url.indexOf( link_url, url.length - link_url.length ) !== -1)
        {
          if (parent_panel !== "#root")
          {
            //push the parent panel if we have one
            $(parent_panel).addClass('pushed');
          }
          
          //push our panel
          nav_panel.addClass('pushed');
          
          //mark our link
          nav_link.addClass('active');
        
          if (link.attr("data-target"))
          {
            //push the child panel if we have one
            var child_panel = $(link.attr("data-target"));
            child_panel.addClass('pushed');
          }
          
          console.log("found");
          found = true; //flag to break outer loop
          return false;
        }
      });
      if (found)
      {
        return false;
      }
    });
  });

}( window.jQuery )