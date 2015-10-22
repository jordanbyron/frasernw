var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");

var Referrals = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      acceptsReferralsViaPhone: React.PropTypes.shape({
        label: React.PropTypes.string,
        value: React.PropTypes.bool
      }),
      patientsCanBook: React.PropTypes.shape({
        label: React.PropTypes.string,
        value: React.PropTypes.bool
      }),
      respondsWithin: React.PropTypes.shape({
        label: React.PropTypes.string,
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
  handlePhoneUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "acceptsReferralsViaPhone",
      update: event.target.checked
    });
  },
  handleRespondsWithinUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "respondsWithin",
      update: parseInt(event.target.value)
    });
  },
  handlePatientsCanBookUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "patientsCanBook",
      update: event.target.checked
    });
  },
  render: function() {
    return (
      <div>
        <CheckBox
          label={this.props.filters.acceptsReferralsViaPhone.label}
          value={this.props.filters.acceptsReferralsViaPhone.value}
          onChange={this.handlePhoneUpdate}
        />
        <Selector
          label={this.props.filters.respondsWithin.label}
          options={this.props.filters.respondsWithin.options}
          value={this.props.filters.respondsWithin.value}
          onChange={this.handleRespondsWithinUpdate}
          style={{width: "100%"}}
        />
        <CheckBox
          changeKey={"patientsCanBook"}
          label={this.props.filters.patientsCanBook.label}
          value={this.props.filters.patientsCanBook.value}
          onChange={this.handlePatientsCanBookUpdate}
        />
      </div>
    );
  }
});
module.exports = Referrals;
