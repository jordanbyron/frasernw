var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");
var checkboxLabelStyle = require("../../stylesets").halfColumnCheckbox;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "sexes",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="male"
          changeKey="male"
          label="Male"
          value={this.props.filters.sexes.male.value}
          onChange={this.handleCheckboxUpdate}
          labelStyle={checkboxLabelStyle}
        />
        <CheckBox
          key={"female"}
          changeKey="female"
          label="Female"
          value={this.props.filters.sexes.female.value}
          onChange={this.handleCheckboxUpdate}
          labelStyle={checkboxLabelStyle}
        />
      </div>
    );
  }
});
