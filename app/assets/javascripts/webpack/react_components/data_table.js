var React = require("react");
var Table = require("./table");
var SidebarLayout = require("./sidebar_layout");
var Filters = require("./filters");
var sortBy = require("lodash/collection/sortBy");
var filterComponents = {
  city: require("./city_filter")
}

var labelSpecialistName = function(record) {
  return (
    <a href={"/specialists/" + record.id}>{ record.name }</a>
  );
}

var labelSpecialistStatus = function(record) {
  return (
    <i className={record.status_icon_classes}></i>
  );
}

var labelSpecialistCities = function(record, labels) {
  return record
    .cityIds
    .map((id) => labels.city[id])
    .join(" and ");
}

var filterByCities = function(record, filters) {
  return record.cityIds.some((id) => filters.city[id]);
}

var rowGenerators = {
  specialist: function(record) {
    var labels = this;

    return {
      cells: [
        labelSpecialistName(record),
        labelSpecialistStatus(record),
        record.waittime,
        labelSpecialistCities(record, labels)
      ],
      reactKey: record.id,
      record: record
    }
  }
}

var rowFilters = {
  specialist: function(record) {
    var filters = this;

    return filterByCities(record, filters);
  }
}

var sortFunctions = {
  specialist: function(sortConfig) {
    switch(sortConfig.column) {
    case "NAME":
      return function(row){ return row.record.name; };
    case "REFERRALS":
      return function(row){ return row.record.status_icon_classes; };
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
  bodyRows: function() {
    var unsorted = this.props.records
      .filter(this.filterFunction(), this.props.filterValues)
      .map(this.rowGenerator(), this.props.labels);

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
  sidebar: function() {
    return (
      <Filters title={this.props.labels.filterSpecialist}>
        {
          this.props.filterComponents.map((filterKey)=>{
            return React.createElement(
              filterComponents[filterKey],
              {
                filters: this.props.filterValues[filterKey],
                labels: this.props.labels[filterKey],
                visible: this.props.filterVisibility[filterKey],
                toggleVisibility: this.toggleFilterVisibility,
                updateFilter: this.updateFilter
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
