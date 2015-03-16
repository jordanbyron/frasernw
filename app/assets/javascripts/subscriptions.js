// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {


  $("#subscription_classification_news_updates").change(function(){ 
    console.log("news update change");
    update_for_classification_change();
  });

  $("#subscription_classification_resource_updates").change(function(){ 
    console.log("resource update change");
    update_for_classification_change();
  });


  var update_for_classification_change = function()
  {
    $('.all-updates').show(); // show form submit options again
    if ($("#subscription_classification_news_updates").is(":checked"))
    {
      console.log("news update checked");
      $(".news-updates").show();
      $(".resource-updates").hide();
    }
    else if ($("#subscription_classification_resource_updates").is(":checked"))
    {
      console.log("resource update checked");
      $(".news-updates").hide();
      $(".resource-updates").show();
    }

  }
  // var news_updates_changed = function(){
  //   alert("news_updates_changed");
  // }
  //$("#subscription_classification_news_updates").live("change", resource_updates_changed);

  //$("#subscription_classification_resource_updates").live("change", news_updates_changed);

  //$("#subscription_classification_resource_updates").prop('checked', true).show()

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