var React = require("react");
var Table = require("./table");
var SidebarLayout = require("./sidebar_layout");
var ResultSummary = require("./result_summary");
var Filters = require("./filters");
var ToggleBox = require("./toggle_box");
var SpecializationFilter = require("./specialization_filter");
var sortBy = require("lodash/collection/sortBy");
var pick = require("lodash/object/pick");
var objectAssign = require("object-assign");
var filterGroups = {
  city: require("./filter_groups/city"),
  procedures: require("./filter_groups/procedures"),
  referrals: require("./filter_groups/referrals"),
  sex: require("./filter_groups/sex"),
  schedule: require("./filter_groups/schedule"),
  languages: require("./filter_groups/languages")
}
var rowFilters = require("../datatable_support/filters");
var rowGenerators = require("../datatable_support/row_generators");
var sortFunctions = require("../datatable_support/sort_functions");
var keysAtTruthyVals = require("../utils").keysAtTruthyVals;
var find = require("lodash/collection/find");

module.exports = React.createClass({
  toggleFilterGroupVisibility: function(key) {
    return ()=> {
      return this.props.dispatch({
        type: "TOGGLE_FILTER_VISIBILITY",
        filterKey: key
      });
    }
  },
  updateFilter: function(filterType, update){
    return this.props.dispatch({
      type: "FILTER_UPDATED",
      filterType: filterType,
      update: update
    });
  },
  handleHeaderClick: function(key) {
    return () => {
      return this.props.dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  handleClearFilters: function(e) {
    e.preventDefault();

    return this.props.dispatch({
      type: "CLEAR_FILTERS",
      filterFunction: this.props.filterFunction
    });
  },
  filterFunction: function() {
    return rowFilters[this.props.filterFunction];
  },
  sortFunction: function() {
    return sortFunctions[this.props.sortFunction];
  },
  rowGenerator: function() {
    return rowGenerators[this.props.rowGenerator];
  },
  labels: function() {
    return objectAssign(
      {},
      this.props.labels,
      this.props.globalData.labels
    );
  },
  generateBodyRows: function(filtered) {
    var unsorted = filtered.map((row) => {
      return this.rowGenerator()(row, this.labels())
    });

    var sorted = sortBy(
      unsorted,
      this.sortFunction()(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  shouldFilterBySpecialization: function() {
    return this.props.specializationFilter &&
      ( this.props.filterValues.specialization ||
      (keysAtTruthyVals(this.props.filterValues.procedures).length != 1));
  },
  mainPanel: function() {
    var preSpecializationFiltered = this.props.records.filter((row) => {
      return this.filterFunction()(row, this.props.filterValues);
    });

    // transparent filter informs the user how many records have been filtered
    // out
    var specializationFiltered = preSpecializationFiltered.filter((record) => {
      return find(record.specializationIds, (id) => {
        return (this.props.filterValues.specializationId === id);
      });
    });
    var remainder = preSpecializationFiltered.length - specializationFiltered.length;

    if (this.shouldFilterBySpecialization()) {
      var bodyRows = this.generateBodyRows(specializationFiltered);
    } else {
      var bodyRows = this.generateBodyRows(preSpecializationFiltered);
    }

    var shouldShowSpecializationFilter = this.props.specializationFilter &&
      (keysAtTruthyVals(this.props.filterValues.procedures).length === 1) &&
      remainder > 0

    return (
      <div>
        <ResultSummary anyResults={(bodyRows.length > 0)}
          bodyRows={bodyRows}
          filterValues={this.props.filterValues}
          labels={this.labels()}
          collectionName={this.props.collectionName}
          filterFunction={this.props.filterFunction}
          handleClearFilters={this.handleClearFilters}
        />
        <SpecializationFilter
          show={shouldShowSpecializationFilter}
          remainder={remainder}
          updateFilter={this.updateFilter}
          showingOtherSpecialties={!this.props.filterValues.specialization}
        />
        <Table
          headings={this.props.tableHeadings}
          bodyRows={bodyRows}
          sortConfig={this.props.sortConfig}
          handleHeaderClick={this.handleHeaderClick}
        />
      </div>
    );
  },
  sidebar: function() {
    return(
      <Filters title={this.props.labels.filterSection}>
        {
          this.props.filterGroups.map((filterKey, index)=>{
            return(
              <ToggleBox
                title={this.props.globalData.labels.filterGroups[filterKey]}
                open={this.props.filterVisibility[filterKey]}
                handleToggle={this.toggleFilterGroupVisibility(filterKey)}
                key={index + this.props.collectionName}
              >
                {
                  React.createElement(
                    filterGroups[filterKey],
                    {
                      filterValues: this.props.filterValues,
                      labels: this.labels(),
                      arrangements: this.props.filterArrangements,
                      updateFilter: this.updateFilter,
                      key: index
                    }
                  )
                }
              </ToggleBox>
            );
          })
        }
      </Filters>
    );
  },
  render: function() {
    console.log('hey');
    return(
      <SidebarLayout
        main={this.mainPanel()}
        sidebar={this.sidebar()}
      />
    );
  }
});
