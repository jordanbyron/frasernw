var React = require('react');
var Hey = require('../react_components/hey')

module.exports = function() {
  $(document).ready(function() {
    React.render(
      <Hey/>,
      document.getElementById("main-nav")
    )
  });
}
