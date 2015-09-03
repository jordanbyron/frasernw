var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  className: function() {
    if (this.props.bodyRows.length > 0) {
      return "filter-phrase";
    } else {
      return "filter-phrase none";
    }
  },
  render: function() {
    var text = this.props.filterSummary;

    if (text.length > 0) {
      return(
        <div className={this.className()} style={{display: "block"}}>
          <span>{ text + ".  " }</span>
          <a onClick={this.props.handleClearFilters} style={buttonIsh}>
            Clear Filters
          </a>
        </div>
      );
    } else {
      return null;
    }
  }
})
