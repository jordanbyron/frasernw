var React = require("react");
var Table = require("../helpers/table");
var CheckBox = require("../helpers/checkbox");
var Redux = require("redux");
var ToggleBox = require("../helpers/toggle_box");
var sortBy = require("lodash/collection/sortBy");
var objectAssign = require("object-assign");

module.exports = React.createClass({
  generateSpecialistLink: function(record) {
    return (
      <a href={"/specialists/" + record.id}>{ record.name }</a>
    );
  },
  generateStatusIcon: function(record) {
    return (
      <i className={record.status_icon_classes}></i>
    );
  },
  generateCities: function(record) {
    return record
      .cityIds
      .map((id) => this.props.labels.city[id])
      .join(" and ");
  },
  rowGenerator: function(record) {
    return {
      cells: [
        this.generateSpecialistLink(record),
        this.generateStatusIcon(record),
        record.waittime,
        this.generateCities(record)
      ],
      reactKey: record.id,
      record: record
    }
  },
  cityFilter: function(record) {
    return record.cityIds.some((id) => this.props.filters.city[id]);
  },
  filterPredicate: function(record) {
    return this.cityFilter(record);
  },
  sortFunction: function() {
    switch(this.props.sortConfig.column) {
    case "NAME":
      return function(row){ return row.record.name; }
    case "REFERRALS":
      return function(row){ return row.record.status_icon_classes; }
    case "WAITTIME":
      return function(row){ return row.record.waittime; }
    case "CITY":
      return function(row){ return row.cells[3]; }
    default:
      return function(row){ return row.record.name; }
    }
  },
  bodyRows: function() {
    var unsorted = this.props.records
      .filter(this.filterPredicate)
      .map(this.rowGenerator);

    var sorted = sortBy(unsorted, this.sortFunction());

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  onFilterUpdate: function(filterType, key) {
    var dispatch = this.props.dispatch;
    return function(event) {
      dispatch({
        type: "FILTER_UPDATED",
        filterType: filterType,
        filterKey: key,
        filterValue: event.target.checked
      });
    };
  },
  filtersAtKey: function(filterKey, labelFunction) {
    var obj = this.props.filters[filterKey];
    var filters = [];
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        filters.push({key: key, value: obj[key], label: labelFunction(key)});
      }
    }
    return filters;
  },
  labelCityFilter: function(cityId) {
    return this.props.labels.city[cityId];
  },
  handleFilterToggle: function(key) {
    return () => {
      return this.props.dispatch({
        type: "TOGGLE_FILTER_VISIBILITY",
        filterKey: key
      });
    };
  },
  handleHeaderClick: function(key) {
    return () => {
      return this.props.dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  selectAllCities: function(e) {
    e.preventDefault();
    this.props.dispatch({
      type: "SELECT_ALL_CITIES"
    });
  },
  deselectAllCities: function(e) {
    e.preventDefault();
    this.props.dispatch({
      type: "DESELECT_ALL_CITIES"
    });
  },
  render: function() {
    return (
      <div className="row">
        <div className="span8">
          <Table
            headings={this.props.tableHeadings}
            bodyRows={this.bodyRows()}
            sortConfig={this.props.sortConfig}
            handleHeaderClick={this.handleHeaderClick}
          />
        </div>
        <div className="span4">
          <div className="well filter" id="specialist_filters">
            <div className="title">{ "Filter Specialists" }</div>
            <ToggleBox title={"City"}
              open={this.props.filterVisibility.city}
              handleToggle={this.handleFilterToggle("city")}>
              {
                this.filtersAtKey("city", this.labelCityFilter).map((filter) => {
                  return <CheckBox
                    key={filter.key}
                    label={filter.label}
                    value={filter.value}
                    onChange={this.onFilterUpdate("city", filter.key)} />;
                })
              }
              <a onClick={this.selectAllCities}
                className="filters__city_select">Select all cities</a>
              <a onClick={this.deselectAllCities}
                className="filters__city_select">Deselect all cities</a>
            </ToggleBox>
          </div>
        </div>
      </div>
    );
  }
});
