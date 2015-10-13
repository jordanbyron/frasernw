var React = require("react");
var Table = require("../react_components/table");
var SidebarLayout = require("./sidebar_layout");
var ResultSummary = require("./result_summary");
var Filters = require("./filters");
var SpecializationFilterMessage = require("./specialization_filter_message");
var CityFilterPills = require("./city_filter_pills");
var IconKeys = {
  specialists: require("./specialist_icon_key"),
  clinics: require("./clinic_icon_key")
}
var ReducedViewSelector = require("./reduced_view_selector");
var AssumedList = require("./assumed_list");

module.exports = React.createClass({
  propTypes: {
    headings: React.PropTypes.array.isRequired,
    bodyRows: React.PropTypes.array.isRequired,
    sortConfig: React.PropTypes.object.isRequired,
    filters: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired
  },
  iconKey: function() {
    if (IconKeys[this.props.iconKey]) {
      return React.createElement(IconKeys[this.props.iconKey]);
    } else {
      return null;
    }
  },
  render: function() {
    return(
      <div>
        <ReducedViewSelector
          dispatch={this.props.dispatch}
          reducedView={this.props.reducedView}
        />
        <SidebarLayout
          main={
            <div>
              <ResultSummary {...this.props.resultSummary} dispatch={this.props.dispatch}/>
              <SpecializationFilterMessage {...this.props.specializationFilterMessage} dispatch={this.props.dispatch}/>
              <CityFilterPills {...this.props.cityFilterPills} dispatch={this.props.dispatch}/>
              <Table
                headings={this.props.headings}
                bodyRows={this.props.bodyRows}
                sortConfig={this.props.sortConfig}
                dispatch={this.props.dispatch}
              />
              <AssumedList {...this.props.assumedList}/>
            </div>
          }
          sidebar={
            <div>
              <Filters
                {...this.props.filters}
                dispatch={this.props.dispatch}
              />
              { this.iconKey() }
            </div>
          }
          reducedView={this.props.reducedView}
        />
      </div>
    );
  }
})
