var React = require("react");
var TableHead = require("./table_head");
var TableBody = require("./table_body");

module.exports = React.createClass({
  render: function() {
    return (
      <table>
        <TableHead data={this.props.headings}/>
        <TableBody rows={this.props.bodyRows}/>
      </table>
    );
  }
});
