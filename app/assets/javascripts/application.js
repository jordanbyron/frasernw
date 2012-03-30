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