var React = require("react");
var ToggleBox = require("../toggle_box");
var Selector = require("../selector");

var Months = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      months: React.PropTypes.shape({
        value: React.PropTypes.number,
        options: React.PropTypes.arrayOf(
          React.PropTypes.shape({
            key: React.PropTypes.number,
            label: React.PropTypes.string
          })
        )
      })
    })
  },
  handleUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "months",
      update: parseInt(event.target.value)
    });
  },
  render: function() {
    return (
      <div>
        <Selector
          options={this.props.filters.months.options}
          value={this.props.filters.months.value}
          onChange={this.handleUpdate}
          style={{width: "100%"}}
        />
      </div>
    );
  }
});
module.exports = Months;
