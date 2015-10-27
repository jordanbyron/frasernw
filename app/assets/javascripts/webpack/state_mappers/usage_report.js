var _ = require("lodash");
var moment = require("moment");
var React = require("react");
var RadioButtons = require("../react_components/radio_buttons");
var Selector = require("../react_components/selector");

module.exports = function(stateProps: Object, dispatchProps: Object): Object {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  var filterValues = _.reduce(GENERATE_FILTER_VALUES, (memo, fn, key) => {
    return _.assign(
      {},
      memo,
      {[key] : fn(state)}
    );
  }, {})

  var requestNewData = generateQuery(state, dispatch);

  if (state.ui.hasBeenInitialized) {
    return {
      title: title(filterValues, state),
      subtitle: subtitle(filterValues.months),
      tableRows: _.get(state, ["ui", "rows"], []),
      filters: {
        title: "Customize Report",
        groups: generateFilterGroups(state, dispatch, requestNewData)
      },
      noticeText: `${_.startCase(filterValues.recordTypes )} page views are only available for November 2015 and later.`,
      dispatch: dispatch,
      isLoading: false,
      isPeriodValid: !(moment(filterValues.month).isBefore("2015-11-01", "months") &&
        _.includes(["physicianResources", "forms", "patientInfo"], filterValues.recordTypes)),
      isTableLoading: _.get(state, ["ui", "isTableLoading"], false),
      query: requestNewData,
      annotation: (ANNOTATIONS[filterValues.recordTypes] || "")
    };
  } else {
    return {
      isLoading: true
    };
  }
};

const SC_ITEM_ANNOTATION = `
  'Page Views' are defined as views of the page at the url that is linked to on user-facing tables
  (i.e. specialization pages).
  Depending on the format of the resource, this may be an external page or a page on Pathways.
`

const ANNOTATIONS = {
  physicianResources: SC_ITEM_ANNOTATION,
  patientInfo: SC_ITEM_ANNOTATION,
  forms: "'Page Views' are defined as views of the uploaded form."
}


var generateQuery = function(state: Object, dispatch: Function): Function {
  var currentParams = {
    record_type: GENERATE_FILTER_VALUES.recordTypes(state),
    division_id: GENERATE_FILTER_VALUES.divisions(state),
    month_key: GENERATE_FILTER_VALUES.months(state)
  };

  return function(triggeringUpdate) {
    var _triggeringUpdate = triggeringUpdate || {};

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

    return true;
  };
}

var scopeLabel = function(filterValues, divisions) {
  if (filterValues.divisions === 0) {
    return "by Page Views";
  } else {
    return ` by ${divisions[filterValues.divisions].name} Users' Page Views`
  }
}
var title = function(filterValues, state) {
  return `Top ${_.startCase(filterValues.recordTypes)} ${scopeLabel(filterValues, state.app.divisions)}`
}
var subtitle = function(monthsFilterValue) {
  return moment(monthsFilterValue, "YYYYMM").format("MMMM YYYY");
}

var generateFilterGroups = function(state: Object, dispatch: Function, requestNewData: Function): Array {
  return [
    {
      title: "Entity Type",
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
      "patientInfo",
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
    var startDate = moment("04-01-2014", "MM-DD-YYYY")
    var endDate = moment().startOf("month");

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
      moment().format("YYYYMM")
    );
  }
};
