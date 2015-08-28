var React = require("react");
var filterSummary = require("../datatable_support/filter_summary");

module.exports = React.createClass({
  render: function() {
    var text = filterSummary(this.props);

    if (text.length > 0) {
      return(
        <div className="filter-phrase" style={{display: "block"}}>
          { filterSummary(this.props) }
        </div>
      );
    } else {
      return null;
    }
  }
})
