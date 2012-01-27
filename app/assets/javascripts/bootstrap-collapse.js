/* =============================================================
 * bootstrap-collapse.js v2.0.0
 * http://twitter.github.com/bootstrap/javascript.html#collapse
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */

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


 /* COLLAPSIBLE DATA-API
  * ==================== */

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