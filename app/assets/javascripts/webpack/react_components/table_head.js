var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

var TableHead = React.createClass({
  propTypes: {
    data: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        label: React.PropTypes.string,
        key: React.PropTypes.string
      })
    ).isRequired,
    sortConfig: React.PropTypes.shape({
      order: React.PropTypes.string.isRequired,
      column: React.PropTypes.string.isRequired
    }).isRequired,
    dispatch: React.PropTypes.func.isRequired
  },
  arrowStyle: {
    color: "#08c",
    marginLeft: "5px"
  },
  handleHeaderClick: function(dispatch, key) {
    return () => {
      return dispatch({
        type: "TOGGLE_ORDER_BY_COLUMN",
        headerKey: key,
        currentColumn: this.props.sortConfig.column,
        currentOrder: this.props.sortConfig.order
      });
    };
  },
  headerCell: function(cell, index) {
    return (
      <th
        key={index}
        onClick={this.handleHeaderClick(this.props.dispatch, cell.key)}
        style={buttonIsh}
        className={cell.className}
      >
        <span>{cell.label}</span>
        { this.arrow(cell) }
      </th>
    );
  },
  arrow: function(cell) {
    var activeKey = this.props.sortConfig.column;
    var order = this.props.sortConfig.order;

    if (cell.key == activeKey && order == "UP"){
      return(<i className="icon-arrow-up" style={this.arrowStyle}></i>);
    } else if (cell.key == activeKey && order == "DOWN") {
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
module.exports = TableHead
