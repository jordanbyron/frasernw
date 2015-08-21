var React = require("react");

module.exports = React.createClass({
  headerCell: function(cell, index) {
    return (
      <th key={index} onClick={this.props.handleClick(cell.key)}>
        <span>{cell.label}</span>
        { this.arrow(cell) }
      </th>
    );
  },
  arrow: function(cell) {
    var activeKey = this.props.sortConfig.column;
    var order = this.props.sortConfig.order;

    if (cell.key == activeKey && order == "ASC"){
      return(<i className="icon-arrow-up"></i>);
    } else if (cell.key == activeKey && order == "DESC") {
      return(<i className="icon-arrow-down"></i>);
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
