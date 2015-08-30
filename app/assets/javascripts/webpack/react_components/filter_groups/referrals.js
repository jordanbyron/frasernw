var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  respondsWithinOptions: function() {
    return this.props.arrangements.respondsWithinOptions.map((optionId) => {
      return {
        key: optionId,
        label: this.props.labels.respondsWithinOptions[optionId]
      }
    })
  },
  handlePhoneUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "acceptsReferralsViaPhone",
      event.target.checked
    );
  },
  handleRespondsWithinUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "respondsWithin",
      event.target.value
    );
  },
  handlePatientsCanBookUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "patientsCanBook",
      event.target.checked
    );
  },
  render: function() {
    return (
      <div>
        <CheckBox
          label={this.props.labels.acceptsReferralsViaPhone}
          value={this.props.filterValues.acceptsReferralsViaPhone}
          onChange={this.handlePhoneUpdate}
        />
        <Selector
          label={this.props.labels.respondsWithin}
          options={this.respondsWithinOptions()}
          value={this.props.filterValues.respondsWithin}
          onChange={this.handleRespondsWithinUpdate}
        />
        <CheckBox
          changeKey={"patientsCanBook"}
          label={this.props.labels.patientsCanBook}
          value={this.props.filterValues.patientsCanBook}
          onChange={this.handlePatientsCanBookUpdate}
        />
      </div>
    );
  }
});