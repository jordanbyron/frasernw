var React = require("react");
var Table = require("./table");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");
var sortBy = require("lodash/collection/sortBy");
var values = require("lodash/object/values");
var every = require("lodash/collection/every");
var objectAssign = require("object-assign");
var filterComponents = {
  city: require("./city_filter"),
  procedureSpecializations: require("./procedure_specializations_filter"),
  referrals: require("./referrals_filter")
}

var labelReferentName = function(record) {
  return (
    <a href={"/" + record.collectionName + "/" + record.id}>{ record.name }</a>
  );
}

var labelReferentStatus = function(record) {
  return (
    <i className={record.statusIconClasses}></i>
  );
}

var labelReferentCities = function(record, labels) {
  return record
    .cityIds
    .map((id) => labels.city[id])
    .join(" and ");
}

var filterByCities = function(record, cityFilters) {
  return record.cityIds.some((id) => cityFilters[id]);
}

var filterByProcedureSpecializations = function(record, psFilters) {
  if (every((values(psFilters)), (value) => !value)) {
    return true;
  } else {
    return record.procedureSpecializationIds.some((id) => psFilters[id]);
  }
}

var filterByReferrals = function(record, referralsFilters) {
  var tests = [
    function(record, filters) {
      return ((filters.acceptsReferralsViaPhone == false) || record.acceptsReferralsViaPhone);
    },
    function(record, filters) {
      return ((filters.patientsCanBook == false) || record.patientsCanBook);
    },
    function(record, filters) {
      return ((filters.respondsWithin == 0) || (record.respondsWithin <= filters.respondsWithin));
    }
  ]

  return every(tests, (test) => test(record, referralsFilters));
}

var rowFilters = {
  referents: function(record) {
    var filters = this;

    return filterByCities(record, filters.city) &&
      filterByProcedureSpecializations(record, filters.procedureSpecializations) &&
      filterByReferrals(record, filters.referrals);
  }
}

var rowGenerators = {
  referents: function(record, labels) {
    return {
      cells: [
        labelReferentName(record),
        labelReferentStatus(record),
        record.waittime,
        labelReferentCities(record, labels)
      ],
      reactKey: record.id,
      record: record
    }
  }
}

var sortFunctions = {
  referents: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return function(row){ return row.record.name; };
    case "REFERRALS":
      return function(row){ return row.record.statusIconClasses; };
    case "WAITTIME":
      return function(row){ return row.record.waittime; };
    case "CITY":
      return function(row){ return row.cells[3]; };
    default:
      return function(row){ return row.record.name; };
    }
  }
}

module.exports = React.createClass({
  toggleFilterVisibility: function(key) {
    return this.props.dispatch({
      type: "TOGGLE_FILTER_VISIBILITY",
      filterKey: key
    });
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
      .filter(this.filterFunction(), this.props.filterValues)
      .map((row) => {
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
    return (
      <Table
        headings={this.props.tableHeadings}
        bodyRows={this.bodyRows()}
        sortConfig={this.props.sortConfig}
        handleHeaderClick={this.handleHeaderClick}
      />
    );
  },
  labelsForFilter: function(filterKey) {
    return this.props.labels[filterKey] || this.props.globalData.labels[filterKey];
  },
  sidebar: function() {
    return (
      <Filters title={this.props.labels.filterSection}>
        {
          this.props.filterComponents.map((filterKey, index)=>{
            return React.createElement(
              filterComponents[filterKey],
              {
                filters: this.props.filterValues[filterKey],
                labels: this.labelsForFilter(filterKey),
                visible: this.props.filterVisibility[filterKey],
                toggleVisibility: this.toggleFilterVisibility,
                updateFilter: this.updateFilter,
                key: index
              }
            )
          })
        }
      </Filters>
    );
  },
  render: function() {
    return (
      <SidebarLayout
        main={this.table()}
        sidebar={this.sidebar()}
      />
    );
  }
});
