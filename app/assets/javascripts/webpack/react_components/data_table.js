var React = require("react");
var Table = require("./table");
var SidebarLayout = require("./sidebar_layout");
var ResultSummary = require("./result_summary");
var Filters = require("./filters");
var ToggleBox = require("./toggle_box");
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
  bodyRows: function() {
    var unsorted = this.props.records
      .filter((row) => {
        return this.filterFunction()(row, this.props.filterValues);
      }).map((row) => {
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
  table: function() {
    var bodyRows = this.bodyRows();

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
                key={index}
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
    return(
      <SidebarLayout
        main={this.table()}
        sidebar={this.sidebar()}
      />
    );
  }
});
