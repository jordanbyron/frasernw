var React = require("react");
var Filters = require("../react_components/partials/specialist_filters");

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

module.exports = {
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
  Filters: Filters
}
