var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var keys = require("lodash/object/keys");
var sortBy = require("lodash/collection/sortBy");
var mapValues = require("lodash/object/mapValues");

module.exports = React.createClass({
  generateFilters: function(filterType) {
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
      "city",
      { [key] : event.target.checked }
    );
  },
  handleSelectAll: function(event) {
    this.props.updateFilter(
      "city",
      mapValues(this.props.filters, (val) => true)
    );
  },
  handleDeselectAll: function(event) {
    this.props.updateFilter(
      "city",
      mapValues(this.props.filters, (val) => false)
    );
  },
  render: function() {
    return (
      <div>
        {
          this.generateFilters().map((filter) => {
            return <CheckBox
              key={filter.key}
              changeKey={filter.key}
              label={filter.label}
              value={filter.value}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
        <a onClick={this.handleSelectAll}
          className="filters__city_select">Select all cities</a>
        <a onClick={this.handleDeselectAll}
          className="filters__city_select">Deselect all cities</a>
      </div>
    );
  }
});
