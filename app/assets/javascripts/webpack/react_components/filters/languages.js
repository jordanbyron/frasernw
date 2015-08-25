var React = require("react");
var CheckBox = require("../checkbox");
var sortBy = require("lodash/collection/sortBy");
var keys = require("lodash/object/keys");

var component = React.createClass({
  propTypes: {
    filters: React.PropTypes.object,
    labels: React.PropTypes.object
  },
  generateFilters: function() {
    return sortBy(keys(this.props.filters).map((key) => {
      return {
        key: key,
        value: this.props.filters[key],
        label: this.props.labels[key]
      };
    }), (city) => city.label);
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.updateFilter(
      "languages",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        {
          this.generateFilters().map((filter) => {
            return (
              <CheckBox
                key={filter.key}
                changeKey={filter.key}
                label={filter.label}
                value={filter.value}
                onChange={this.handleCheckboxUpdate}
              />
            );
          })
        }
      </div>
    );
  }
});

module.exports = component;
