var React = require("react");
var TableRow = require("./table_row");

module.exports = React.createClass({
  render: function() {
    return (
      <tbody>
        {
          this.props.rows.map(function (row) {
            return (
              <TableRow data={row.cells} key={row.reactKey} />
            );
          })
        }
      </tbody>
    );
  }
});
