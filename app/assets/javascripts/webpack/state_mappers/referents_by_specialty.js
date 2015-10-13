var _ = require("lodash");

module.exports = function(stateProps, dispatchProps) {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  console.log(state);

  if (state.ui.hasBeenInitialized) {
    return {
      title: "Pathways Specialists",
      lists: lists(state),
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
      isOpen: true,
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
      isOpen: true,
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


var lists = function(state) {
  var filtered = filterReferents(_.values(state.app[FILTER_VALUE_GENERATORS.recordTypes(state)]), state);

  return _.values(state.app.specializations).map((specialization) => {
    return {
      title: specialization.name,
      items: specializationReferents(filtered, specialization.id),
      key: specialization.id
    };
  });
};

var filterReferents = function(referents: Array, state: Object): Array {
  var filterValues = _.transform(FILTER_VALUE_GENERATORS, (memo, fn, key) => {
    memo[key] = fn(state)
  });

  var activatedFilters =
    _.values(filters).filter((filter) => filter.isActivated(filterValues));

  return referents.filter((referent) => {
    return _.every(activatedFilters, (filter) => filter.predicate(referent, filterValues));
  });
};

var specializationReferents = function(referents, specializationId) {
  return referents.filter((referent) => {
    return _.includes(referent.specializationIds, specializationId);
  }).map((referent) => referent.name);
};
