var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");

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
      "referrals",
      { [key] : event.target.checked }
    );
  },
  handleSelectorUpdate: function(event, key) {
    this.props.updateFilter(
      "referrals",
      { [key] : event.target.value }
    );
  },
  render: function() {
    return (
      <div>
        <CheckBox
          changeKey={"acceptsReferralsViaPhone"}
          label={this.props.labels.acceptsReferralsViaPhone}
          value={this.props.filters.acceptsReferralsViaPhone}
          onChange={this.handleCheckboxUpdate}
        />
        <Selector
          changeKey={"respondsWithin"}
          label={this.props.labels.respondsWithin.self}
          options={this.props.labels.respondsWithin.values}
          value={this.props.filters.respondsWithin}
          onChange={this.handleSelectorUpdate}
        />
        <CheckBox
          changeKey={"patientsCanBook"}
          label={this.props.labels.patientsCanBook}
          value={this.props.filters.patientsCanBook}
          onChange={this.handleCheckboxUpdate}
        />
      </div>
    );
  }
});
