var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");

var Divisions = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      divisions: React.PropTypes.shape({
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
  handleDivisionsUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "divisions",
      update: parseInt(event.target.value)
    });
  },
  render: function() {
    return (
      <div>
        <Selector
          label={this.props.filters.divisions.label}
          options={this.props.filters.divisions.options}
          value={this.props.filters.divisions.value}
          onChange={this.handleDivisionsUpdate}
          style={{width: "100%"}}
        />
      </div>
    );
  }
});
module.exports = Divisions;
