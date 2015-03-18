// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {


  $("#subscription_classification_news_updates").change(function (){ 
    update_for_classification_change();
  });

  $("#subscription_classification_resource_updates").change(function (){ 
    update_for_classification_change();
  });


  var update_for_classification_change = function ()
  {
    $('.all-updates').show(); // show form options applying to both categories again
    if ($("#subscription_classification_news_updates").is(":checked"))
    {
      $(".resource-updates").hide();
      $(".news-updates").fadeIn(300).show();

    }
    else if ($("#subscription_classification_resource_updates").is(":checked"))
    {
      $(".news-updates").hide();
      $(".resource-updates").fadeIn(300).show();
    }

  }


  $('#all_news_types').on('click', function(e) {
       $('.news_type-option').prop('checked', $(e.target).prop('checked'));
   });

  $('#all_sc_categories').on('click', function(e) {
       $('.sc_category-option').prop('checked', $(e.target).prop('checked'));
   });

  $('#all_specializations').on('click', function(e) {
       $('.specialization-option').prop('checked', $(e.target).prop('checked'));
   });

  $('#all_divisions').on('click', function(e) {
       $('.division-option').prop('checked', $(e.target).prop('checked'));
   });

});
