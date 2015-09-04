var React = require("react");
var sortBy = require("lodash/collection/sortBy");
var find = require("lodash/collection/find");
var keysAtTruthyVals = require("../utils").keysAtTruthyVals;
var values = require("lodash/object/values");
var every = require("lodash/collection/every");
var DataTable = require("../react_mixins/data_table");
var ResultSummary = require("./result_summary");
var SpecializationFilter = require("./specialization_filter");
var Table = require("./table");
var getFilterSummary = require("../datatable_support/filter_summary");
var rowFilters = require("../datatable_support/filters");
var rowGenerators = require("../datatable_support/row_generators");
var sortFunctions = require("../datatable_support/sort_functions");
var SidebarLayout = require("./sidebar_layout");
var pick = require("lodash/object/pick");
var Filters = require("./filters");
var ToggleableFilterGroup = require("./toggleable_filter_group");

module.exports = React.createClass({
  generateBodyRows: function(filtered) {
    var unsorted = filtered.map((row) => {
      return rowGenerators.resources(row, DataTable.labels(this.props))
    });

    var sorted = sortBy(
      unsorted,
      sortFunctions.resources(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  filters: function() {
    return pick(rowFilters, ["subcategories"]);
  },
  sidebar: function() {
    return(
      <Filters title={this.props.labels.filterSection}>
        <ToggleableFilterGroup
          {...DataTable.toggleableFilterProps(this.props, "subcategories")}/>
      </Filters>
    );
  },
  mainPanel: function() {
    var operativeFilters = values(this.filters()).filter(
      (predicate) => predicate.isActivated(this.props.filterValues)
    );

    var filtered = this.props.records.filter((row) => {
      return every(
        operativeFilters,
        (filter) => filter.predicate(row, this.props.filterValues)
      );
    });

    var bodyRows = this.generateBodyRows(filtered);

    var filterSummary = getFilterSummary(operativeFilters, {
      labels: DataTable.labels(this.props),
      filterValues: this.props.filterValues,
      bodyRows: bodyRows,
      collectionName: this.props.collectionName
    });

    return (
      <div>
        <ResultSummary anyResults={(bodyRows.length > 0)}
          bodyRows={bodyRows}
          filterSummary={filterSummary}
          handleClearFilters={DataTable.handleClearFilters(this.props.dispatch)}
        />
        <Table
          headings={this.props.tableHeadings}
          bodyRows={bodyRows}
          sortConfig={this.props.sortConfig}
          dispatch={this.props.dispatch}
        />
      </div>
    );
  },
  render: function() {
    return(
      <SidebarLayout
        main={this.mainPanel()}
        sidebar={this.sidebar()}
      />
    );
  }
})
