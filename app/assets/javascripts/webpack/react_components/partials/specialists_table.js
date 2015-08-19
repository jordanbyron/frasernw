var React = require("react");
var Table = require("../helpers/table");
var objectAssign = require("object-assign");

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

var labelSpecialistCities = function(record, component) {
  return record
    .cityIds
    .map((id) => component.props.labels.city[id])
    .join(" and ");
}

var filterByCities = function(record, component) {
  return record.cityIds.some((id) => component.props.filters.city[id]);
}

module.exports = React.createClass({
  generateRow: function(record) {
    return {
      cells: [
        labelSpecialistName(record),
        labelSpecialistStatus(record),
        record.waittime,
        labelSpecialistCities(record, this)
      ],
      reactKey: record.id,
      record: record
    }
  },
  filterRow: function(record) {
    return filterByCities(record, this);
  },
  sortFunction: function(sortConfig) {
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
  },
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
  table: function() {
    return (
      <DataTable
        {...this.props}
        filterRow={this.filterRow}
        generateRow={this.generateRow}
        sortFunction={this.sortFunction}
      />
    );
  };
  sidebar: function() {
    return (
      <Filters title="Filter Specialists">
        <CityFilter
          filters={this.props.filters.city}
          labels={this.props.labels.city}
          visible={this.props.filterVisibility.city}
          toggleVisibility={this.toggleFilterVisibility}
          updateFilter={this.updateFilter}
        />
      </Filters>
    );
  }
  render: function() {
    return (
      <SidebarLayout
        main={this.table()}
        sidebar={this.sidebar()}
      />
    );
  }
});
