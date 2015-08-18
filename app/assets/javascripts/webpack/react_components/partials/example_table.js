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
      <div>
        <Table
          headings={this.props.headings}
          bodyRows={this.bodyRows()}
        />
        <div>
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
    );
  }
});
