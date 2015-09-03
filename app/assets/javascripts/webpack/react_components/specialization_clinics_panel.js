var React = require("react");
var DataTable = require("../react_mixins/data_table");
var SpecializationReferentMainPanel = require("./specialization_referent_panel");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");
var ToggleableFilterGroup = require("./toggleable_filter_group");
var rowFilters = require("../datatable_support/filters");
var rowGenerators = require("../datatable_support/row_generators");
var sortFunctions = require("../datatable_support/sort_functions");
var pick = require("lodash/object/pick");




module.exports = React.createClass({
  sidebar: function() {
    var toggleableFilterProps =
      DataTable.toggleableFilterProps(this.props)

    return(
      <Filters title={this.props.labels.filterSection}>
        <ToggleableFilterGroup
          filterGroupKey="procedures"
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          filterGroupKey="referrals"
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          filterGroupKey="clinicDetails"
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          filterGroupKey="schedule"
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          filterGroupKey="languages"
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          filterGroupKey="city"
          {...toggleableFilterProps}/>
      </Filters>
    );
  },
  filterKeys: [
    "cities",
    "acceptsReferralsViaPhone",
    "patientsCanBook",
    "respondsWithin",
    "procedures",
    "referrals",
    "languages",
    "schedule",
    "private",
    "public",
    "wheelchairAccessible"
  ],
  rowFilters: function() {
    return pick(rowFilters, this.filterKeys);
  },
  render: function() {
    return(
      <SidebarLayout
        main={
          <SpecializationReferentMainPanel
            {...this.props}
            filterPredicates={this.rowFilters()}
            sortFunction={sortFunctions.referents}
            rowGenerator={rowGenerators.referents}
            filterFunctionName="clinics"
          />
        }
        sidebar={this.sidebar()}
      />
    );
  }
});
