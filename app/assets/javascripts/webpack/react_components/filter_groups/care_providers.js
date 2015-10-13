var React = require("react");
var CheckBox = require("../checkbox");
var mask = require("../../utils").mask;

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      careProviders: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          label: React.PropTypes.string,
          value: React.PropTypes.bool,
          filterKey: React.PropTypes.string,
        })
      )
    })
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "careProviders",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        {
          this.props.filters.careProviders.map((careProvider) => {
            return <CheckBox
              key={careProvider.filterId}
              changeKey={careProvider.filterId}
              label={careProvider.label}
              value={careProvider.value}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
      </div>
    );
  }
});
