// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery-1.7.2.min
//= require jquery-ui
//= require jquery_ujs
//= require jquery.scrollto.min.js
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/2/jquery.dataTables.bootstrap
//= require json2.js
//= require jquery.history.js
//= require jquery_nested_form.js
//= require ajaxify-html5.js
//= require_directory .

function current_user_is_admin()
{
  return ($('body').data('GLOBAL_USER_TYPE') === 0);
}

Array.prototype.to_sentence = function() {
  return this.join(", ").replace(/,\s([^,]+)$/, ' and $1')
}

Array.prototype.unique = function() {
  var a = this.concat();
  for(var i=0; i<a.length; ++i) {
    for(var j=i+1; j<a.length; ++j) {
      if(a[i] === a[j])
        a.splice(j, 1);
    }
  }
  return a;
};

Array.prototype.intersect = function(a2)
{
  var a1 = this;
  var a = [];
  var l = a1.length;
  var l2 = a2.length;
  for(var i=0; i<l; i++)
  {
    for(var j=0; j<l2; j++)
    {
      if (a1[i] === a2[j])
      {
        a.push(a1[i]);
      }
    }
  }
  return a.unique();
};

// Production steps of ECMA-262, Edition 5, 15.4.4.19
// Reference: http://es5.github.com/#x15.4.4.19
if (!Array.prototype.map) {
  Array.prototype.map = function(callback, thisArg) {

    var T, A, k;

    if (this == null) {
      throw new TypeError(" this is null or not defined");
    }

    var O = Object(this);
    var len = O.length >>> 0;

    if (typeof callback !== "function") {
      throw new TypeError(callback + " is not a function");
    }

    if (thisArg) {
      T = thisArg;
    }

    A = new Array(len);

    k = 0;

    while(k < len) {
      var kValue, mappedValue;
      if (k in O) {
        kValue = O[ k ];
        mappedValue = callback.call(T, kValue, k, O);
        A[ k ] = mappedValue;
      }
      k++;
    }

    return A;
  };
}

if(!Array.indexOf) {
  Array.prototype.indexOf = function(obj) {
    for (var i=0; i < this.length; i++) {
      if (this[i] == obj) {
        return i;
      }
    }
    return -1;
  }
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
      var favorite_heart = $('#user_favorite_' + type + '_' + id);
      if (data)
      {
        favorite_heart.removeClass('icon-text');
        favorite_heart.addClass('icon-red');   //make the heart red
        $('#add_favorites').hide();                 //hide the favorites description
        $('#' + type + '_favorites').show();        //show the favorites section header if it isn't already
        $('#' + type + '_favorites').after('<li class=\"favorite\" id=\"' + type + '_' + id + '\"><a class=\"ajax\" href=\"/' + type + '/' + id + '\">' + name + '</a></li>');
      }
      else
      {
        favorite_heart.removeClass('icon-red');
        favorite_heart.addClass('icon-text');
        $('#favorites_dropdown li#' + type + '_' + id).remove()
        if ( $('#favorites_dropdown li[id^=' + type + ']').length == 1 )
        {
          //hide the favorites section header if there isn't any other items
          $('#' + type + '_favorites').hide();
        }
        if ( $('#favorites_dropdown li').length == 4 )
        {
          //show the favorites description if only it an the headings are all that's left
          $('#add_favorites').show();
        }
      }
    }
  });
}

function update_favorites() {
  $('#favorites_dropdown li.favorite').each( function() {
    var attr_id = $(this).attr('id');
    var favorite_heart = $('#user_favorite_' + attr_id);
    favorite_heart.removeClass('icon-text');
    favorite_heart.addClass('icon-red');
  });
}
