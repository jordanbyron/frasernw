var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var keys = require("lodash/object/keys");
var sortBy = require("lodash/collection/sortBy");
var mapValues = require("lodash/object/mapValues");
var updateFilter = require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "city",
      { [key] : event.target.checked }
    );
  },
  handleSelectAll: function(event) {
    updateFilter(
      this.props.dispatch,
      "city",
      mapValues(this.props.filterValues.city, (val) => true)
    );
  },
  handleDeselectAll: function(event) {
    updateFilter(
      this.props.dispatch,
      "city",
      mapValues(this.props.filterValues.city, (val) => false)
    );
  },
  render: function() {
    return (
      <div>
        {
          this.props.arrangements.city.map((id) => {
            return <CheckBox
              key={id}
              changeKey={id}
              label={this.props.labels.city[id]}
              value={this.props.filterValues.city[id]}
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
