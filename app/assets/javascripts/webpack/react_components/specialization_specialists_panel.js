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
          dataKey={"procedures"}
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          dataKey={"referrals"}
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          dataKey={"sex"}
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          dataKey={"schedule"}
          {...toggleableFilterProps}/>
        <ToggleableFilterGroup
          dataKey={"languages"}
          {...toggleableFilterProps}/>
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
      "languages",
      "sex"
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
