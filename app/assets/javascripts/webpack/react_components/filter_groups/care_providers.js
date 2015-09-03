var React = require("react");
var CheckBox = require("../checkbox");
var updateFilter = require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "careProviders",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        {
          this.props.arrangements.careProviders.map((id) => {
            return <CheckBox
              key={id}
              changeKey={id}
              label={this.props.labels.careProviders[id]}
              value={this.props.filterValues.careProviders[id]}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
      </div>
    );
  }
});
