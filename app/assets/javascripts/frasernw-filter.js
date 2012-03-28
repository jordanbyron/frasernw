!function( $ ){

  "use strict"

  $(function() {
    $('body').on('click.data-api', '[data-toggle=filter]', function ( e ) {
               
      var $this = $(this),
        target_name = $this.attr('data-target') || e.preventDefault()
        , target = $(target_name)
        , new_filter = $this.attr('data-filter') || e.preventDefault()
        , filtered = !$this.hasClass('filtered');
                 
      var current_filters = target.data('filters');
      console.log( "before: " + current_filters )
                 
      if (filtered)
      {
        $this.addClass('filtered');
        if (!current_filters)
        {
          target.data('filters', new_filter)
        }
        else 
        {
          target.data('filters', current_filters + ' ' + new_filter)
        }
      }
      else
      {
        $this.removeClass('filtered');
        if (current_filters) 
        {
          target.data('filters', current_filters.replace(new_filter,'').replace('  ',' ').trim() ) 
        }
      }
             
      current_filters = target.data('filters')
      console.log( "after: " + current_filters )
      current_filters = current_filters.split(' ')
                 
      $(target_name + ' tbody tr').each(function () {
        var row = $(this)
          , row_filter = row.data('filter');
        if (!row_filter || (current_filters.length == 0))
        {
          row.hide();
          return true;
        }
        var show = true;
        for (var i = 0; i < current_filters.length; ++i)
        {
          if (row_filter.indexOf(current_filters[i]) == -1)
          {
            show = false;
            break;
          }
        }
        show ? row.show() : row.hide();   
      });
    });
  }); 

}( window.jQuery )