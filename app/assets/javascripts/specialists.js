var status_changed = function() 
{
  if ( $(this).val() == "5" )
  {
    //"retiring as of"
    $(".unavailable_from").show();
    $(".unavailable_to").hide();
  }
  else if ( $(this).val() == "6" )
  {
    //"unavaiable between"
    $(".unavailable_from").show();
    $(".unavailable_to").show();
  }
  else
  {
    $(".unavailable_from").hide();
    $(".unavailable_to").hide();
  }
}

$("#specialist_status_mask").live("change", status_changed );


$("#add_address").live("click", function() {
                       $(this).hide()
                       });