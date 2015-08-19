var React = require("react");
var Table = require("../helpers/table");
var CheckBox = require("../helpers/checkbox");
var Redux = require("redux");
var ToggleBox = require("../helpers/toggle_box");
var sortBy = require("lodash/collection/sortBy");
var objectAssign = require("object-assign");
var configs = require("../../datatable_configs.manifest.js");

module.exports = React.createClass({
  config: function() { return configs["specialist"]; },
  bodyRows: function() {
    var unsorted = this.props.records
      .filter(this.config().filterRow, this)
      .map(this.config().generateRow, this);

    var sorted = sortBy(
      unsorted,
      this.config().sortFunction(this.props.sortConfig)
    );

    if (this.props.sortConfig.order == "DESC"){
      return sorted.reverse();
    } else {
      return sorted;
    }
  },
  handleHeaderClick: function(key) {
    return () => {
      return this.props.dispatch({
        type: "HEADER_CLICK",
        headerKey: key
      });
    };
  },
  filtersProps: function() {
    return {
      filters: this.props.filters,
      labels: this.props.labels,
      filterVisibility: this.props.filterVisibility,
      toggleFilterVisibility: (key) => {
        return this.props.dispatch({
          type: "TOGGLE_FILTER_VISIBILITY",
          filterKey: key
        });
      },
      updateFilter: (filterType, update) => {
        return this.props.dispatch({
          type: "FILTER_UPDATED",
          filterType: filterType,
          update: update
        });
      }
    };
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
            {
              React.createElement(
                this.config()["Filters"],
                this.filtersProps()
              )
            }
          </div>
        </div>
      </div>
    );
  }
});
