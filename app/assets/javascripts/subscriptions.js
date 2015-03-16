// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {


  $("#subscription_classification_news_updates").change(function (){ 
    console.log("news update change");
    update_for_classification_change();
  });

  $("#subscription_classification_resource_updates").change(function (){ 
    console.log("resource update change");
    update_for_classification_change();
  });


  var update_for_classification_change = function ()
  {
    $('.all-updates').show(); // show form submit options again
    if ($("#subscription_classification_news_updates").is(":checked"))
    {
      console.log("news update checked");
      $(".resource-updates").hide();
      $(".news-updates").fadeIn(300).show();

    }
    else if ($("#subscription_classification_resource_updates").is(":checked"))
    {
      console.log("resource update checked");
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



// $("#subscription_specialization_ids_" + value).prop("checked", true);


  // $.fn.fix_radios = function () {
  //   function focus() {
  //     if ( !this.checked ) return;
  //     if ( !this.was_checked ) {
  //       $( this ).change();
  //     }
  //   }

  //   function change( e ) {
  //     if ( this.was_checked ) {
  //       e.stopImmediatePropagation();
  //       return;
  //     }
  //     $( "input[name=" + this.name + "]" ).each( function() {
  //       this.was_checked = this.checked;
  //     } );
  //   }
  //   return this.focus( focus ).change( change );
  // }


  // $(function() {
  //   $( "input[type=radio]" ).fix_radios();
  //   $("input[name='subscription[classification]']").change(function(){
  //     if ($("input[name='subscription[classification]']:checked").val() == 'News Updates'){
  //       $(".news-updates").show();
  //       $(".resource-updates").hide();
  //     } else {
  //       alert("do other stuff");
  //       $(".news-updates").hide();
  //       $(".resource-updates").show();
  //     }
  //   });
  // });



});

// var hideall = function(){

// $(".news-updates").hide();
// $(".resource-updates").hide();


// };

// hideall;

//                                                           


//BEST Working example ATM:
// $(document).on(function() {

//   $.fn.fix_radios = function() {
//     function focus() {
//       if ( !this.checked ) return;
//       if ( !this.was_checked ) {
//         $( this ).change();
//       }
//     }

//     function change( e ) {
//       if ( this.was_checked ) {
//         e.stopImmediatePropagation();
//         return;
//       }
//       $( "input[name=" + this.name + "]" ).each( function() {
//         this.was_checked = this.checked;
//       } );
//     }
//     return this.focus( focus ).change( change );
//   }

//   $(function() {
//     $( "input[type=radio]" ).fix_radios();
//     $("input[name='subscription[classification]']").change(function(){
//       if ($("input[name='subscription[classification]']:checked").val() == 'News Updates'){
//         $(".news-updates").show();
//         $(".resource-updates").hide();
//       } else {
//         alert("do other stuff");
//         $(".news-updates").hide();
//         $(".resource-updates").show();
//       }
//     });
//   });
// });






// $.fn.fix_radios = function() {
//   function focus() {
//     // if this isn't checked then no option is yet selected. bail
//     if ( !this.checked ) return;

//     // if this wasn't already checked, manually fire a change event
//     if ( !this.was_checked ) {
//       $( this ).change();
//     }
//   }

//   function change( e ) {
//     // shortcut if already checked to stop IE firing again
//     if ( this.was_checked ) {
//       e.stopImmediatePropagation();
//       return;
//     }

//     // reset all the was_checked properties
//     $( "input[name=" + this.name + "]" ).each( function() {
//       this.was_checked = this.checked;
//     } );
//   }

//   // attach the handlers and return so chaining works
//   return this.focus( focus ).change( change );
// }

// // attach it to all radios on document ready
// $( function() {
//   $( "input[type=radio]" ).fix_radios();
// } );