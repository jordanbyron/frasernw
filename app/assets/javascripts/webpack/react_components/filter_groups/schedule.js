var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "schedule",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        {
          this.props.arrangements.schedule.map((key) => {
            return (
              <CheckBox
                key={key}
                changeKey={key}
                label={this.props.labels.schedule[key]}
                value={this.props.filterValues.schedule[key]}
                onChange={this.handleCheckboxUpdate}
              />
            );
          })
        }
      </div>
    );
  }
});
