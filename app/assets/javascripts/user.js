var swapRole = function() 
{
  if ( $(this).val() == "super" )
  {
    $("#super_admin_pane").show();
    $("#admin_pane").hide();
    $("#user_pane").hide();
  }
  else if ( $(this).val() == "admin" )
  {
    $("#super_admin_pane").hide();
    $("#admin_pane").show();
    $("#user_pane").hide();
  }
  else
  {
    $("#super_admin_pane").hide();
    $("#admin_pane").hide();
    $("#user_pane").show();
  }
}

$("#user_role").live("change", swapRole );