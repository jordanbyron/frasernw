var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  render: function() {
    return (
      <tr className="datatable__row" style={buttonIsh} onClick={this.props.onClick}>
        {
          this.props.data.map(function(cell, i) {
            return (
              <td key={i} className="datatable__cell">{cell}</td>
            );
          })
        }
      </tr>
    );
  }
});
