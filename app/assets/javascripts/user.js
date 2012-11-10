var swapRole = function() 
{
  if ( $(this).val() == "super" )
  {
    $("#admin_and_super_admin_pane").show();
    $("#super_admin_pane").show();
    $("#admin_pane").hide();
    $("#user_pane").hide();
  }
  else if ( $(this).val() == "admin" )
  {
    $("#admin_and_super_admin_pane").show();
    $("#super_admin_pane").hide();
    $("#admin_pane").show();
    $("#user_pane").hide();
  }
  else
  {
    $("#admin_and_super_admin_pane").hide();
    $("#super_admin_pane").hide();
    $("#admin_pane").hide();
    $("#user_pane").show();
  }
}

$("#user_role").live("change", swapRole );