var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.object,
    labels: React.PropTypes.object,
    arrangement: React.PropTypes.array
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.updateFilter(
      "schedule",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        {
          this.props.arrangement.map((key) => {
            return (
              <CheckBox
                key={key}
                changeKey={key}
                label={this.props.labels[key]}
                value={this.props.filters[key]}
                onChange={this.handleCheckboxUpdate}
              />
            );
          })
        }
      </div>
    );
  }
});
