var _ = require("lodash");
var moment = require("moment");
var React = require("react");
var RadioButtons = require("../react_components/radio_buttons");
var Selector = require("../react_components/selector");

module.exports = function(stateProps: Object, dispatchProps: Object): Object {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  if (state.ui.hasBeenInitialized) {
    return {
      title: "Usage report",
      tableRows: _.get(state, ["ui", "rows"], []),
      filters: {
        title: "Customize Report",
        groups: generateFilterGroups(state, dispatch)
      },
      dispatch: dispatch,
      isLoading: false,
      isTableLoading: _.get(state, ["ui", "isTableLoading"], false)
    };
  } else {
    return {
      isLoading: true
    };
  }
};


var generateFilterGroups = function(state: Object, dispatch: Function): Array {
  var currentParams = {
    record_type: GENERATE_FILTER_VALUES.recordTypes(state),
    division_id: GENERATE_FILTER_VALUES.divisions(state),
    month_key: GENERATE_FILTER_VALUES.months(state)
  };

  var requestNewData = function(triggeringUpdate: Object) {
    $.get("/api/v1/reports/usage", _.assign(
      {},
      currentParams,
      triggeringUpdate
    )).done(function(data) {
      dispatch({
        type: "UPDATE_ROWS",
        rows: data.rows
      })
    })
  };

  return [
    {
      title: "Record Type",
      isOpen: _.get(state, ["ui", "filterVisibility", "recordTypes"], true),
      componentKey: "recordTypes",
      contents: (
        <RadioButtons
          options={GENERATE_FILTER_OPTIONS.recordTypes(state)}
          handleChange={
            function(event) {
              dispatch({
                type: "ASYNC_FILTER_UPDATE",
                filterType: "recordTypes",
                update: event.target.value
              });

              requestNewData({ record_type: event.target.value });
            }
          }
        />
      )
    },
    {
      title: "Divisions",
      isOpen: _.get(state, ["ui", "filterVisibility", "divisions"], true),
      componentKey: "divisions",
      contents: (
        <Selector
          options={GENERATE_FILTER_OPTIONS.divisions(state)}
          value={GENERATE_FILTER_VALUES.divisions(state)}
          onChange={
            function(event) {
              dispatch({
                type: "ASYNC_FILTER_UPDATE",
                filterType: "divisions",
                update: parseInt(event.target.value)
              });

              requestNewData({ division_id: event.target.value })
            }
          }
          style={{width: "100%"}}
        />
      )
    },
    {
      title: "Month",
      isOpen: _.get(state, ["ui", "filterVisibility", "months"], true),
      componentKey: "months",
      contents: (
        <Selector
          options={GENERATE_FILTER_OPTIONS.months(state)}
          value={GENERATE_FILTER_VALUES.months(state)}
          onChange={
            function(event) {
              dispatch({
                type: "ASYNC_FILTER_UPDATE",
                filterType: "months",
                update: parseInt(event.target.value)
              });

              requestNewData({ month_key: event.target.value })
            }
          }
          style={{width: "100%"}}
        />
      )
    }
  ];
}

const GENERATE_FILTER_OPTIONS = {
  recordTypes: function(state: Object): Array {
    return [
      "specialists",
      "clinics",
      "physicianResources",
      "patientResources",
      "forms",
      "specialties"
    ].map((key) => {
      return {
        label: _.startCase(key),
        key: key,
        checked: GENERATE_FILTER_VALUES.recordTypes(state) === key
      };
    })
  },
  divisions: function(state: Object): Array {
    return [{key: 0, label: "All of Pathways"}].concat(
      _.chain(state.app.divisions)
        .values()
        .filter((division) => {
          if (state.app.currentUser.isSuperAdmin) {
            return true;
          } else {
            return _.includes(state.app.currentUser.divisionIds, division.id);
          }
        })
        .map((division) => ({ label: division.name, key: division.id }))
        .sortBy("label")
        .value()
    );
  },
  months: function(): Array {
    var startDate = moment("01-01-2014", "MM-DD-YYYY")
    var endDate = moment().startOf("month").subtract(1, "months");

    return _.sortByOrder(mapMonths(startDate, endDate, (moment) => {
      return {
        label: moment.format("MMM YYYY"),
        key: moment.format("YYYYMM")
      };
    }), "key", "desc");
  }
}

var mapMonths = function(startDate, endDate, callback, memo = []) {
  if (startDate.isSame(endDate)) {
    return memo.concat(callback(startDate));
  } else {
    return mapMonths(
      moment(startDate).add(1, "months"),
      endDate,
      callback,
      memo.concat(callback(startDate))
    );
  }
}

const GENERATE_FILTER_VALUES = {
  recordTypes: function(state) {
    return _.get(state, ["ui", "filterValues", "recordTypes"], "specialists");
  },
  divisions: function(state) {
    return _.get(state, ["ui", "filterValues", "divisions"], 0);
  },
  months: function(state) {
    return _.get(
      state,
      ["ui", "filterValues", "months"],
      moment().subtract(1, "months").format("YYYYMM")
    );
  }
};
