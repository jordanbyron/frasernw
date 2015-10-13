var React = require("react");
var RadioButtons = require("../radio_buttons");

var RecordTypes = React.createClass({
  propTypes: {
    recordTypes: React.PropTypes.shape({
      options: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          key: React.PropTypes.number,
          label: React.PropTypes.string,
          checked: React.PropTypes.bool
        })
      )
    })
  },
  handleClick: function(event) {
    if (event.target.checked) {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "recordTypes",
        update: event.target.value
      })
    }
  },
  render: function() {
    return (
      <div>
        <RadioButtons
          options={this.props.filters.recordTypes.options}
          handleClick={this.handleClick}
        />
      </div>
    );
  }
});
module.exports = RecordTypes;
