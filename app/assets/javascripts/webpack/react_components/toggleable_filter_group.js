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
  languages: require("./filter_groups/languages"),
  associations: require("./filter_groups/associations"),
  clinicDetails: require("./filter_groups/clinic_details"),
  careProviders: require("./filter_groups/care_providers"),
  subcategories: require("./filter_groups/subcategories")
}

module.exports = React.createClass({
  render: function() {
    var filterGroupKey = this.props.filterGroupKey;

    return(
      <ToggleBox
        title={this.props.labels.filterGroups[filterGroupKey]}
        open={this.props.filterVisibility[filterGroupKey]}
        handleToggle={toggleFilterGroupVisibility(this.props.dispatch, filterGroupKey)}
        key={filterGroupKey + this.props.collectionName}
      >
        {
          React.createElement(
            filterGroups[filterGroupKey],
            {
              filterValues: this.props.filterValues,
              labels: this.props.labels,
              arrangements: this.props.arrangements,
              dispatch: this.props.dispatch,
              key: filterGroupKey
            }
          )
        }
      </ToggleBox>
    );
  }
})
