var React = require("react");
var TableHead = require("./table_head");
var TableBody = require("./table_body");

module.exports = React.createClass({
  render: function() {
    return (
      <table className="table data_table">
        <TableHead data={this.props.headings}
          sortConfig={this.props.sortConfig}
          handleClick={this.props.handleHeaderClick}/>
        <TableBody rows={this.props.bodyRows}/>
      </table>
    );
  }
});
