// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


// var hideall = function(){

// $(".news-updates").hide();
// $(".resource-updates").hide();


// };

// hideall;

// $("#subscription_classification_news_updates").change(alert("hello"));


// BEST Working example ATM:
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