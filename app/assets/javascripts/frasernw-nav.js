!function( $ ){

  "use strict"

  var nav_transition = function ( target, method, startEvent, completeEvent ) 
  {
    var that = $(target)
    , complete = function () {
      that.trigger(completeEvent)
    }
    
    $(target)
      .trigger(startEvent)
      [method]('pushed')
    
    $.support.transition && $(target).hasClass('nav_panel') ?
      $(target).one($.support.transition.end, complete) :
      complete()
  }

  var nav_push = function ( target ) {
    $(target).each(function () {
      nav_transition(target, 'addClass', 'show', 'shown')
    })
  }

  var nav_pop = function ( target ) {
    $(target).each(function () {
      nav_transition(target, 'removeClass', 'hide', 'hidden')
    })
  }

  $(function () {
    $('body').on('click.nav_panel.data-api', '[data-toggle=push]', function ( e ) {
      var $this = $(this)
        , target = $this.attr('data-target') || e.preventDefault() || $this.attr('href')
      nav_push(target)
    })
    
    $('body').on('click.nav_panel.data-api', '[data-toggle=pop]', function ( e ) {
      var $this = $(this)
        , target = $this.attr('data-target') || e.preventDefault() || $this.attr('href')
      nav_pop(target)
    })
  })

}( window.jQuery )