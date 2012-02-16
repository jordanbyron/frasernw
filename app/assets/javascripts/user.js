var swapRole = function() 
{
  if ( $(this).val() == "admin" )
  {
    $("#admin_pane").show();
    $("#user_pane").hide();
  }
  else
  {
    $("#admin_pane").hide();
    $("#user_pane").show();
  }
}

$("#user_role").live("change", swapRole );