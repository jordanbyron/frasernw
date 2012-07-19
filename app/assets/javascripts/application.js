// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery-1.7.1.min
//= require jquery_ujs
//= require jquery.scrollto.min.js
//= require jquery.history.js
//= require ajaxify-html5.js
//= require_tree .

Array.prototype.to_sentence = function() {
  return this.join(", ").replace(/,\s([^,]+)$/, ' and $1')
}

if(typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, '');
  }
}

function favorite(type, id, name) {
  $.ajax({
    url: '/favorites/' + type + '/' + id,
    type: "PUT",
    data: "",
    dataType: 'json',
    success: function(data)
    {
      if (data)
      {
        $('#user_favorite').removeClass('icon-text');
        $('#user_favorite').addClass('icon-red');   //make the heart red
        $('#add_favorites').hide();                 //hide the favorites description
        $('#' + type + '_favorites').show();        //show the favorites section header if it isn't already
        $('#' + type + '_favorites').after('<li id=\"' + type + '_' + id + '\"><a class=\"ajax\" href=\"/' + type + '/' + id + '\">' + name + '</a></li>');
      }
      else
      {
        $('#user_favorite').removeClass('icon-red');
        $('#user_favorite').addClass('icon-text');
        $('#favorites_dropdown li#' + type + '_' + id).remove()
        if ( $('#favorites_dropdown li[id^=' + type + ']').length == 1 )
        {
          //hide the favorites section header if there isn't any other items
          $('#' + type + '_favorites').hide();        
        }
        if ( $('#favorites_dropdown li').length == 5 )
        {
          //show the favorites description if only it an the headings are all that's left
          $('#add_favorites').show();
        }
      }
    }
  });
}