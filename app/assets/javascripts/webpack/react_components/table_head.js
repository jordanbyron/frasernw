var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  arrowStyle: {
    color: "#08c",
    marginLeft: "5px"
  },
  headerCell: function(cell, index) {
    return (
      <th
        key={index}
        onClick={this.props.handleClick(cell.key)}
        style={buttonIsh}
      >
        <span>{cell.label}</span>
        { this.arrow(cell) }
      </th>
    );
  },
  arrow: function(cell) {
    var activeKey = this.props.sortConfig.column;
    var order = this.props.sortConfig.order;

    if (cell.key == activeKey && order == "ASC"){
      return(<i className="icon-arrow-up" style={this.arrowStyle}></i>);
    } else if (cell.key == activeKey && order == "DESC") {
      return(<i className="icon-arrow-down" style={this.arrowStyle}></i>);
    } else {
      return null;
    }
  },
  render: function() {
    return (
      <thead>
        <tr>
          { this.props.data.map(this.headerCell) }
        </tr>
      </thead>
    );
  }
});
