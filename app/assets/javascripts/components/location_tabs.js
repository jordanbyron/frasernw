$(document).ready(function(){
  $("input.location").change(function(e){
    location_name = $(e.target).attr("name");

    // 'change' captures toggle on only
    if ($(e.target).val() == "Not used") {
      $(".tabbable.location_tabs").find("." + location_name).removeClass("emphasized");
    } else {
      $(".tabbable.location_tabs").find("." + location_name).addClass("emphasized");
    }
  });
});
