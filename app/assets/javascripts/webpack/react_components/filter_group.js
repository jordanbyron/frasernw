var React = require("react");
var ToggleBox = require("./toggle_box");
var FILTER_GROUPS = {
  cities: require("./filter_groups/cities"),
  procedures: require("./filter_groups/procedures"),
  referrals: require("./filter_groups/referrals"),
  sexes: require("./filter_groups/sexes"),
  scheduleDays: require("./filter_groups/schedule_days"),
  languages: require("./filter_groups/languages"),
  associations: require("./filter_groups/associations"),
  clinicDetails: require("./filter_groups/clinic_details"),
  careProviders: require("./filter_groups/care_providers"),
  subcategories: require("./filter_groups/subcategories"),
  divisions: require("./filter_groups/divisions"),
  recordTypes: require("./filter_groups/record_types"),
  reportView: require("./filter_groups/report_view")
}

var FilterGroup = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired,
    isOpen: React.PropTypes.bool.isRequired,
    isExpanded: React.PropTypes.bool,
    componentKey: React.PropTypes.string.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    filters: React.PropTypes.object
  },
  toggleFilterGroupVisibility: function(dispatch, key) {
    return ()=> {
      return dispatch({
        type: "TOGGLE_FILTER_GROUP_VISIBILITY",
        filterKey: key,
        isOpen: this.props.isOpen
      });
    }
  },
  render: function() {
    return(
      <ToggleBox
        title={this.props.title}
        open={this.props.isOpen}
        handleToggle={this.toggleFilterGroupVisibility(this.props.dispatch, this.props.componentKey)}
      >
        {
          React.createElement(
            FILTER_GROUPS[this.props.componentKey],
            {
              filters: this.props.filters,
              dispatch: this.props.dispatch,
              isExpanded: this.props.isExpanded
            }
          )
        }
      </ToggleBox>
    );
  }
})
module.exports = FilterGroup;
