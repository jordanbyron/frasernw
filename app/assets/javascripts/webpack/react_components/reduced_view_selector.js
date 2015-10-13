var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh

module.exports = React.createClass({
  handleClick: function(e) {
    e.preventDefault();

    var newView = {
      main: "sidebar",
      sidebar: "main"
    }[this.props.reducedView];

    this.props.dispatch({
      type: "TOGGLE_REDUCED_VIEW",
      newView: newView
    })
  },
  text: function() {
    if (this.props.reducedView === "main") {
      return "Show Filters";
    } else {
      return "Show Table";
    }
  },
  render: function() {
    return(
      <div className="toggle-filters visible-phone">
        <a onClick={this.handleClick} style={buttonIsh}>
          <i className="icon-blue icon-cog icon-small"></i>
          <span style={{marginLeft: "3px"}}>{ this.text() }</span>
        </a>
      </div>
    );
  }
})
