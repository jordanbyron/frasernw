var React = require("react");
var buttonIsh = require("../../stylesets").buttonIsh

module.exports = React.createClass({
  render: function() {
    if (this.props.shouldDisplay) {
      return(<i className={`icon-star icon-${this.props.color}`} style={{marginRight: "5px"}}/>);
    } else {
      return null;
    }
  }
})
