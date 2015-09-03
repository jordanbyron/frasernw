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


module.exports = React.createClass({
  generateBodyRows: function(filtered) {
    var unsorted = filtered.map((row) => {
      return this.props.rowGenerator(row, DataTable.labels(this.props))
    });

    var sorted = sortBy(
      unsorted,
      this.props.sortFunction(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  shouldFilterBySpecialization: function() {
    return ( this.props.filterValues.specialization ||
      (keysAtTruthyVals(this.props.filterValues.procedures).length != 1));
  },
  render: function() {
    var operativeFilters = values(this.props.filterPredicates).filter(
      (predicate) => predicate.isActivated(this.props.filterValues)
    );

    var preSpecializationFiltered = this.props.records.filter((row) => {
      return every(
        operativeFilters,
        (filter) => filter.predicate(row, this.props.filterValues)
      );
    });

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

    var filterSummary = getFilterSummary(operativeFilters, {
      labels: DataTable.labels(this.props),
      filterValues: this.props.filterValues,
      bodyRows: bodyRows,
      collectionName: this.props.collectionName
    });

    var shouldShowSpecializationFilter =
      (keysAtTruthyVals(this.props.filterValues.procedures).length === 1) &&
      remainder > 0

    return (
      <div>
        <ResultSummary anyResults={(bodyRows.length > 0)}
          bodyRows={bodyRows}
          filterSummary={filterSummary}
          handleClearFilters={DataTable.handleClearFilters(this.props.dispatch, this.props.filterFunctionName)}
        />
        <SpecializationFilter
          show={shouldShowSpecializationFilter}
          remainder={remainder}
          dispatch={this.props.dispatch}
          showingOtherSpecialties={!this.props.filterValues.specialization}
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
})
