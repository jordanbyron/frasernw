var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handlePublicUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "public",
      event.target.checked
    );
  },
  handlePrivateUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "private",
      event.target.checked
    );
  },
  handleWheelchairAccessibleUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "wheelchairAccessible",
      event.target.checked
    );
  },
  render: function() {
    return (
      <div>
        <CheckBox
          label="Public"
          value={this.props.filterValues.public}
          onChange={this.handlePublicUpdate}
        />
        <CheckBox
          label="Private"
          value={this.props.filterValues.private}
          onChange={this.handlePrivateUpdate}
        />
        <CheckBox
          label="Wheelchair Accessible"
          value={this.props.filterValues.wheelchairAccessible}
          onChange={this.handleWheelchairAccessibleUpdate}
        />
      </div>
    );
  }
});
