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
          { filterSummary(this.props) }
        </div>
      );
    } else {
      return null;
    }
  }
})
