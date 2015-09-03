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
    return(
      <Filters title={this.props.labels.filterSection}>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "procedures")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "referrals")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "sex")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "schedule")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "languages")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "associations")}/>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "city")}/>
      </Filters>
    );
  },
  rowFilters: function() {
    return pick(rowFilters, [
      "cities",
      "acceptsReferralsViaPhone",
      "patientsCanBook",
      "respondsWithin",
      "procedures",
      "referrals",
      "schedule",
      "languages",
      "sex",
      "clinicAssociation",
      "hospitalAssociation"
    ]);
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
            filterFunctionName="specialists"
          />
        }
        sidebar={this.sidebar()}
      />
    );
  }
});
