
/*
$("#container a").pjax('#container').live('click', function(){})
    
$('body').live('end.pjax', function() {
    $("#container a").pjax('#container');
    $('.tablesorter').tablesorter();
  });
*/

function ajaxto(src)
{
  $.ajax({
          url: src,
          dataType: 'html',
          beforeSend: function(xhr){
            xhr.setRequestHeader('X-PJAX', 'true');
          },
          success: function(data){
            $('#container', window.parent.document).html(data);
            window.parent.history.pushState(null, $(data).filter('title').text(), src);
          }
         });
  /*
  $.pjax({
         url: src,
         container: '#container'
   });
   */
}
