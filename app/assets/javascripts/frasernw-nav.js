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

}( window.jQuery )