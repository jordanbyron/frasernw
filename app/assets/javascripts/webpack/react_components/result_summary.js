var React = require("react");
var filterSummary = require("../datatable_support/filter_summary");

module.exports = React.createClass({
  phrase: function() {
    return ;
  },
  render: function() {
    return(
      <div className="filter-phrase" style={{display: "block"}}>
        { filterSummary(this.props) }
      </div>
    );
  }
})
