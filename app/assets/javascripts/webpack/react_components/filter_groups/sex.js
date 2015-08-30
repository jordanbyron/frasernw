var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "sex",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="male"
          changeKey="male"
          label={"Male"}
          value={this.props.filterValues.male}
          onChange={this.handleCheckboxUpdate}
        />
        <CheckBox
          key={"female"}
          changeKey={"female"}
          label={"Female"}
          value={this.props.filterValues.female}
          onChange={this.handleCheckboxUpdate}
        />
      </div>
    );
  }
});
