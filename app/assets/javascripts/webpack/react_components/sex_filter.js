var React = require("react");
var ToggleBox = require("./toggle_box");
var CheckBox = require("./checkbox");
var Selector = require("./selector");

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      acceptsReferralsViaPhone: React.PropTypes.bool,
      respondsWithin: React.PropTypes.number,
      patientsCanBook: React.PropTypes.bool
    }),
    labels: React.PropTypes.shape({
      acceptsReferralsViaPhone: React.PropTypes.string,
      respondsWithin: React.PropTypes.shape({
        self: React.PropTypes.string,
        values: React.PropTypes.array
      }),
      patientsCanBook: React.PropTypes.string
    })
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.updateFilter(
      "sex",
      { [key] : event.target.checked }
    );
  },
  handleToggleVisibility: function(event) {
    this.props.toggleVisibility("sex");
  },
  render: function() {
    return (
      <ToggleBox title={"Sex"}
        open={this.props.visible}
        handleToggle={this.handleToggleVisibility}>
        {
          this.props.labels.map((label, index) => {
            return (
              <CheckBox
                key={index}
                changeKey={label.key}
                label={label.label}
                value={this.props.filters[label.key]}
                onChange={this.handleCheckboxUpdate}
              />
            );
          })
        }
      </ToggleBox>
    );
  }
});
