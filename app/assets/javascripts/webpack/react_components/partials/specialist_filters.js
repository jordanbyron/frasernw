var React = require("react");
var CityFilter = require("./city_filter");

module.exports = React.createClass({
  render: function() {
    return (
      <CityFilter
        filters={this.props.filters.city}
        labels={this.props.labels.city}
        toggleVisibility={this.props.toggleFilterVisibility}
        updateFilter={this.props.updateFilter}
        visible={this.props.filterVisibility.city}
      />
    );
  }
});
