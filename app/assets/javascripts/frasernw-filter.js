!function( $ ){

  "use strict"

  var filter = function(target, metric, filtered) 
  {
    console.log('filter: ' + target + " :: " + metric);
    $(target + ' tr').each(function () {
      var $this = $(this),
        filter_data = $this.data("filter");
      if (!filter_data)
      {
        return true;
      }
      filtered ? ( filter_data.indexOf(metric) == -1 ? $this.hide() : $this.show() ) : $this.show();
    })
  }

  $(function() {
    $('body').on('click.data-api', '[data-toggle=filter]', function ( e ) {
                 
       var $this = $(this),
         target = $this.attr('data-target') || e.preventDefault()
         , metric = $this.attr('data-metric') || e.preventDefault()
         , filtered = $this.hasClass('filtered');
         filtered ? $this.removeClass('filtered') : $this.addClass('filtered')
       filter(target, metric, !filtered);
    })
  })

}( window.jQuery )