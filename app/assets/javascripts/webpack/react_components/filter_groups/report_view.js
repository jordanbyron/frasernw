var React = require("react");
var RadioButtons = require("../radio_buttons");

var ReportView = React.createClass({
  propTypes: {
    reportView: React.PropTypes.shape({
      options: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          key: React.PropTypes.string,
          label: React.PropTypes.string,
          checked: React.PropTypes.bool
        })
      )
    })
  },
  handleChange: function(event) {
    if (event.target.checked) {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "reportView",
        update: event.target.value
      })
    }
  },
  render: function() {
    return (
      <div>
        <RadioButtons
          options={this.props.filters.reportView.options}
          handleChange={this.handleChange}
        />
      </div>
    );
  }
});
module.exports = ReportView;
