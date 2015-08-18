var React = require("react");
var Table = require("../helpers/table");
var Redux = require("redux");

module.exports = React.createClass({
  rowGenerator: function(record) {
    return [
      record.id,
      record.name,
      record.date,
      "www.hey.com"
    ];
  },
  filterPredicate: function(record) {
    return true;
  },
  bodyRows: function() {
    return this.props.records
      .filter(this.filterPredicate)
      .map(this.rowGenerator);
  },
  render: function() {
    return (
      <Table
        headings={this.props.headings}
        bodyRows={this.bodyRows()}
      />
    );
  }
});
