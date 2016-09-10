// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function(){

  $("#subscription_target_class_newsitem").change(function (){
    update_for_classification_change();
  });

  $("#subscription_target_class_scitem").change(function (){
    update_for_classification_change();
  });


  // Make form section appear/disappear
  var update_for_classification_change = function ()
  {
    $('.all-updates').show(); // show form options applying to both categories again
    if ($("#subscription_target_class_newsitem").is(":checked"))
    {
      $(".content-item-updates").hide();
      $(".news-updates").fadeIn(300).show();

    }
    else if ($("#subscription_target_class_scitem").is(":checked"))
    {
      $(".news-updates").hide();
      $(".content-item-updates").fadeIn(300).show();
    }

  }

  // Refresh 'Check All' checkbox after each checklist change

  $('.news_type-option').on( "click", function() {
    if ($('.news_type-option').length === $('.news_type-option').filter(':checked').length)
    {
      document.getElementById('all_news_types').checked = 1;
    }
    else if($('.news_type-option').length != $('.news_type-option').filter(':checked').length)
    {
      document.getElementById('all_news_types').checked = 0;
    }
  });

  $('.sc_item_format_type-option').on( "click", function() {
    if ($('.sc_item_format_type-option').length === $('.sc_item_format_type-option').filter(':checked').length)
    {
      document.getElementById('all_sc_item_format_types').checked = 1;
    }
    else if($('.sc_item_format_type-option').length != $('.sc_item_format_type-option').filter(':checked').length)
    {
      document.getElementById('all_sc_item_format_types').checked = 0;
    }
  });

  $('.sc_category-option').on( "click", function() {
    if ($('.sc_category-option').length === $('.sc_category-option').filter(':checked').length)
    {
      document.getElementById('all_sc_categories').checked = 1;
    }
    else if($('.sc_category-option').length != $('.sc_category-option').filter(':checked').length)
    {
      document.getElementById('all_sc_categories').checked = 0;
    }
  });

  $('.specialization-option').on( "click", function() {
    if ($('.specialization-option').length === $('.specialization-option').filter(':checked').length)
    {
      document.getElementById('all_specializations').checked = 1;
    }
    else if($('.specialization-option').length != $('.specialization-option').filter(':checked').length)
    {
      document.getElementById('all_specializations').checked = 0;
    }
  });

  $('.division-option').on( "click", function() {
    if ($('.division-option').length === $('.division-option').filter(':checked').length)
    {
      document.getElementById('all_divisions').checked = 1;
    }
    else if($('.division-option').length != $('.division-option').filter(':checked').length)
    {
      document.getElementById('all_divisions').checked = 0;
    }
  });

  // 'Check all' action for filling every checkbox within each list"

  $('#all_news_types').on('click', function(e) {
       $('.news_type-option').prop('checked', $(e.target).prop('checked'));
   });

  $('#all_sc_item_format_types').on('click', function(e) {
       $('.sc_item_format_type-option').prop('checked', $(e.target).prop('checked'));
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
