var React = require("react");
var TableHead = require("./table_head");
var TableBody = require("./table_body");

module.exports = React.createClass({
  propTypes: {
    headings: React.PropTypes.array.isRequired,
    sortConfig: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    bodyRows: React.PropTypes.array.isRequired
  },
  render: function() {
    return (
      <table className="table data_table">
        <TableHead data={this.props.headings}
          sortConfig={this.props.sortConfig}
          dispatch={this.props.dispatch}
        />
        <TableBody rows={this.props.bodyRows}/>
      </table>
    );
  }
});
