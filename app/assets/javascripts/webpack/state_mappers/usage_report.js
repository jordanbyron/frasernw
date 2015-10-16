var _ = require("lodash");
var moment = require("moment");

module.exports = function(stateProps: Object, dispatchProps: Object): Object {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  if (state.ui.hasBeenInitialized) {
    return {
      title: "Usage report",
      tableRows: [],
      filters: {
        title: "Customize Report",
        groups: generateFilterGroups(state)
      },
      dispatch: dispatch,
      isLoading: false
    };
  } else {
    return {
      isLoading: true
    };
  }
};

var generateFilterGroups = function(state: Object): Array {
  return [
    {
      title: "Record Type",
      isOpen: _.get(state, ["ui", "filterVisibility", "recordTypes"], true),
      componentKey: "recordTypes",
      filters: {
        recordTypes: {
          options: GENERATE_FILTER_OPTIONS.recordTypes(state)
        }
      }
    },
    {
      title: "Divisions",
      isOpen: _.get(state, ["ui", "filterVisibility", "divisions"], true),
      componentKey: "divisions",
      filters: {
        divisions: {
          value: GENERATE_FILTER_VALUES.divisions(state),
          options: GENERATE_FILTER_OPTIONS.divisions(state)
        }
      }
    },
    {
      title: "Month",
      isOpen: _.get(state, ["ui", "filterVisibility", "months"], true),
      componentKey: "months",
      filters: {
        months: {
          value: GENERATE_FILTER_VALUES.months(state),
          options: GENERATE_FILTER_OPTIONS.months(state)
        }
      }
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
        .filter((division) => _.includes(state.app.currentUser.divisionIds, division.id))
        .map((division) => ({ label: division.name, key: division.id }))
        .sortBy("label")
        .value()
    );
  },
  months: function(): Array {
    var startDate = moment("01-01-2014", "MM-DD-YYYY")
    var endDate = moment().startOf("month").subtract(1, "months");

    return mapMonths(startDate, endDate, (moment) => {
      return {
        label: moment.format("MMM YYYY"),
        key: moment.format("MMYYYY")
      };
    });
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
      moment().subtract(1, "months").format("MMYYYY")
    );
  }
};
