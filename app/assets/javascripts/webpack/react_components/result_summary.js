var React = require("react");
var filterSummary = require("../datatable_support/filter_summary");

module.exports = React.createClass({
  className: function() {
    if (this.props.bodyRows.length > 0) {
      return "filter-phrase";
    } else {
      return "filter-phrase none";
    }
  },
  render: function() {
    var text = filterSummary(this.props);

    if (text.length > 0) {
      return(
        <div className={this.className()} style={{display: "block"}}>
          <span>{ filterSummary(this.props) + ".  " }</span>
          <a onClick={this.props.handleClearFilters}>Clear Filters</a>
        </div>
      );
    } else {
      return null;
    }
  }
})
