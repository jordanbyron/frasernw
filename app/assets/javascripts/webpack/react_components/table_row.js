var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  render: function() {
    if (this.props.isSelected) {
      var className = "datatable__row datatable__row--isSelected";
    }
    else {
      var className = "datatable__row";
    }

    return (
      <tr
        className={className}
        style={buttonIsh}
        onClick={this.props.onClick}
      >
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
