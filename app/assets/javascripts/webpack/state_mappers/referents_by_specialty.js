var _ = require("lodash");

module.exports = function(stateProps, dispatchProps) {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  console.log(state);

  if (state.ui.hasBeenInitialized) {
    var filterValues = _.transform(FILTER_VALUE_GENERATORS, (memo, fn, key) => {
      memo[key] = fn(state)
    });
    var filtered = filterReferents(
      _.values(state.app[filterValues.recordTypes]),
      state,
      filterValues
    );

    return {
      title: title(state, filterValues, filtered.length),
      lists: lists(state, filtered),
      filters: {
        title: "Customize Report",
        groups: filterGroups(state)
      },
      isLoading: false,
      dispatch: dispatch
    };
  } else {
    return {
      isLoading: true
    };
  }
};


var scopeTitle = function(state, filterValues) {
  if (filterValues.divisions === 0) {
    return "Pathways";
  } else {
    return state.app.divisions[filterValues.divisions].name;
  }
}
var title = function(state, filterValues, resultCount) {
  return `${scopeTitle(state, filterValues)} ${_.capitalize(filterValues.recordTypes)} (${resultCount} total)`
};

const FILTER_VALUE_GENERATORS = {
  divisions: function(state) {
    return _.get(state, ["ui", "filterValues", "divisions"], 0);
  },
  recordTypes: function(state) {
    return _.get(state, ["ui", "filterValues", "recordTypes"], "specialists");
  }
};

var filterGroups = function(state) {
  return [
    {
      title: "Record Type",
      isOpen: _.get(state, ["ui", "filterVisibility", "recordTypes"], true),
      componentKey: "recordTypes",
      filters: {
        recordTypes: {
          options: [
            {
              label: "Specialists",
              key: "specialists",
              checked: FILTER_VALUE_GENERATORS.recordTypes(state) === "specialists"
            },
            {
              label: "Clinics",
              key: "clinics",
              checked: FILTER_VALUE_GENERATORS.recordTypes(state) === "clinics"
            }
          ]
        }
      }
    },
    {
      title: "Divisions",
      isOpen: _.get(state, ["ui", "filterVisibility", "divisions"], true),
      componentKey: "divisions",
      filters: {
        divisions: {
          value: FILTER_VALUE_GENERATORS.divisions(state),
          options: _.values(state.app.divisions).map((division) => {
            return {
              label: division.name,
              key: division.id
            };
          }).concat({key: 0, label: "All of Pathways"})
        }
      }
    }
  ];
};

var filters = {
  divisions: {
    isActivated: function(filterValues) {
      return filterValues.divisions !== 0;
    },
    predicate: function(record, filterValues) {
      return _.includes(record.divisionIds, filterValues.divisions);
    }
  }
}


var lists = function(state, filtered: Array) {
  return _.values(state.app.specializations).map((specialization) => {
    var items = specializationReferents(filtered, specialization.id);

    return {
      title: `${specialization.name} (${items.length} total)`,
      items: specializationReferents(filtered, specialization.id),
      key: specialization.id
    };
  });
};

var filterReferents = function(referents: Array, state: Object, filterValues: Object): Array {
  var activatedFilters =
    _.values(filters).filter((filter) => filter.isActivated(filterValues));

  return referents.filter((referent) => {
    return _.every(activatedFilters, (filter) => filter.predicate(referent, filterValues));
  });
};

var specializationReferents = function(referents, specializationId) {
  return referents.filter((referent) => {
    return _.includes(referent.specializationIds, specializationId);
  }).map((referent) => {
    return {
      content: referent.name,
      reactKey: referent.id
    };
  });
};
