var React = require("react");
var toggleFilterGroupVisibility =
  require("../react_mixins/data_table").toggleFilterGroupVisibility;
var ToggleBox = require("./toggle_box");
var filterGroups = {
  city: require("./filter_groups/city"),
  procedures: require("./filter_groups/procedures"),
  referrals: require("./filter_groups/referrals"),
  sex: require("./filter_groups/sex"),
  schedule: require("./filter_groups/schedule"),
  languages: require("./filter_groups/languages")
}

module.exports = React.createClass({
  render: function() {
    var filterKey = this.props.dataKey;

    return(
      <ToggleBox
        title={this.props.labels.filterGroups[filterKey]}
        open={this.props.filterVisibility[filterKey]}
        handleToggle={toggleFilterGroupVisibility(this.props.dispatch, filterKey)}
        key={filterKey + this.props.collectionName}
      >
        {
          React.createElement(
            filterGroups[filterKey],
            {
              filterValues: this.props.filterValues,
              labels: this.props.labels,
              arrangements: this.props.arrangements,
              dispatch: this.props.dispatch,
              key: filterKey
            }
          )
        }
      </ToggleBox>
    );
  }
})
