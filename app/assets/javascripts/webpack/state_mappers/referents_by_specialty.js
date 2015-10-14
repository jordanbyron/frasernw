var _ = require("lodash");
var React = require("react");

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
      contentComponentType: filterValues.reportView,
      contentComponentProps: contentComponentProps(filterValues, state, filtered),
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

var contentComponentProps = function(filterValues, state, filtered) {
  if (filterValues.reportView === "expanded"){
    return {
      lists: lists(state, filtered, filterValues.recordTypes)
    };
  } else {
    return {
      rows: rows(state, filtered),
      collectionName: _.capitalize(filterValues.recordTypes)
    };
  }
};

var rows = function(state, filtered) {
  return _.sortBy(_.values(state.app.specializations).map((specialization) => {
    var matchingItems = filtered.filter((item) => {
      return _.includes(item.specializationIds, specialization.id);
    })

    return {
      reactKey: specialization.id,
      cells: [ specialization.name, matchingItems.length ]
    }
  }).filter((row) => row.cells[1] > 0), (row) => row.cells[0]);
}

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
  },
  reportView: function(state) {
    return _.get(state, ["ui", "filterValues", "reportView"], "summary");
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
    },
    {
      title: "Report View",
      isOpen: _.get(state, ["ui", "filterVisibility", "reportView"], true),
      componentKey: "reportView",
      filters: {
        reportView: {
          options: [
            {
              label: "Summary",
              key: "summary",
              checked: FILTER_VALUE_GENERATORS.reportView(state) === "summary"
            },
            {
              label: "Expanded",
              key: "expanded",
              checked: FILTER_VALUE_GENERATORS.reportView(state) === "expanded"
            }
          ]
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


var lists = function(state, filtered: Array, collectionName: string) {
  return _.sortBy(_.values(state.app.specializations).map((specialization) => {
    var items = specializationReferents(filtered, specialization.id);

    return {
      title: `${specialization.name} (${items.length} total)`,
      items: specializationReferents(filtered, specialization.id, collectionName),
      isOpen: _.get(state, ["ui", "listVisibility", specialization.id], true),
      key: specialization.id
    };
  }).filter((specialization) => specialization.items.length > 0), "title");
};

var filterReferents = function(referents: Array, state: Object, filterValues: Object): Array {
  var activatedFilters =
    _.values(filters).filter((filter) => filter.isActivated(filterValues));

  return referents.filter((referent) => {
    return _.every(activatedFilters, (filter) => filter.predicate(referent, filterValues));
  });
};

var specializationReferents = function(referents, specializationId, collectionName) {
  return referents.filter((referent) => {
    return _.includes(referent.specializationIds, specializationId);
  }).map((referent) => {
    return {
      content: <a href={`/${collectionName}/${referent.id}`}>{referent.name}</a>,
      reactKey: referent.id
    };
  });
};
