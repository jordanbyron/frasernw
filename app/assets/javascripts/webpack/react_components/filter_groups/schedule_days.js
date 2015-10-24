var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var checkboxLabelStyle = require("../../stylesets").halfColumnCheckbox;

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      scheduleDays: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          filterId: React.PropTypes.string,
          value: React.PropTypes.bool,
          label: React.PropTypes.string
        })
      )
    })
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "scheduleDays",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        {
          this.props.filters.scheduleDays.map((day) => {
            return (
              <CheckBox
                key={day.filterId}
                changeKey={day.filterId}
                label={day.label}
                value={day.value}
                onChange={this.handleCheckboxUpdate}
                labelStyle={checkboxLabelStyle}
              />
            );
          })
        }
      </div>
    );
  }
});
