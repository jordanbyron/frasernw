var React = require("react");
var Table = require("../helpers/table");
var CheckBox = require("../helpers/checkbox");
var Redux = require("redux");
var ToggleBox = require("../helpers/toggle_box");
var sortBy = require("lodash/collection/sortBy");
var objectAssign = require("object-assign");

module.exports = React.createClass({
  bodyRows: function() {
    var unsorted = this.props.records
      .filter(this.props.filterRow, this)
      .map(this.props.generateRow, this);

    var sorted = sortBy(
      unsorted,
      this.props.sortFunction(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  handleHeaderClick: function(key) {
    return () => {
      return this.props.dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  render: function() {
    return (
      <Table
        headings={this.props.tableHeadings}
        bodyRows={this.bodyRows()}
        sortConfig={this.props.sortConfig}
        handleHeaderClick={this.handleHeaderClick}
      />
    );
  }
});
