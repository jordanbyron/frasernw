var React = require("react");
var Table = require("../helpers/table");
var CheckBox = require("../helpers/checkbox");
var Redux = require("redux");

module.exports = React.createClass({
  rowGenerator: function(record) {
    return [
      record.id,
      record.name,
      record.date,
      "www.hey.com"
    ];
  },
  filterPredicate: function(record) {
    return this.props.filters.id[record.id];
  },
  bodyRows: function() {
    return this.props.records
      .filter(this.filterPredicate)
      .map(this.rowGenerator);
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
  idFilters: function() {
    var obj = this.props.filters.id;
    var filters = [];
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        filters.push({key: key, value: obj[key]});
      }
    }
    return filters;
  },
  render: function() {
    var onFilterUpdate = this.onFilterUpdate;
    return (
      <div className="row">
        <div className="span8">
          <Table
            headings={this.props.headings}
            bodyRows={this.bodyRows()}
          />
        </div>
        <div className="span4">
          <div className="well filter" id="specialist_filters">
            <div className="title">{ "Filter Specialists" }</div>
            <div className="filter_group--title">{ "Id" }</div>
            <div className="filter_group--filters">
              {
                this.idFilters().map(function(filter) {
                  return <CheckBox
                    key={filter.key}
                    label={filter.key}
                    value={filter.value}
                    onChange={onFilterUpdate("ID", filter.key)} />;
                })
              }
            </div>
          </div>
        </div>
      </div>
    );
  }
});
