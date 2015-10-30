var _ = require("lodash");
var React = require("react");

module.exports = function(stateProps, dispatchProps) {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

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
      contentComponentProps: contentComponentProps(filterValues, state, filtered, dispatch),
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


var contentComponentProps = function(filterValues, state, filtered, dispatch) {
  if (filterValues.reportView === "expanded"){
    return {
      lists: lists(state, filtered, filterValues.recordTypes)
    };
  } else {
    var sortConfig = {
      order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
      column: _.get(state, ["ui", "sortConfig", "column"], "SPECIALTY")
    }

    return {
      rows: rows(state, filtered, sortConfig),
      tableHead: tableHead(sortConfig, filterValues),
      dispatch: dispatch
    };
  }
};

var tableHead = function(sortConfig, filterValues) {
  return {
    data: [
      { label: "Specialty", key: "SPECIALTY" },
      { label: _.capitalize(filterValues.recordTypes), key: "ENTITY_COUNT" }
    ],
    sortConfig: sortConfig
  };
};

var rows = function(state, filtered, sortConfig) {
  return _.chain(state.app.specializations)
    .values()
    .map((specialization) => {
    var matchingItems = filtered.filter((item) => {
      return _.includes(item.specializationIds, specialization.id);
    })

    return {
      reactKey: specialization.id,
      cells: [ specialization.name, matchingItems.length ]
    }
  }).filter((row) => row.cells[1] > 0)
  .sortByOrder(sortByOrderCallback(sortConfig.column), sortByOrderDirection(sortConfig))
  .value();
}

var sortByOrderCallback = _.curry(function(sortConfigColumn, row) {
  return row.cells[{
    SPECIALTY: 0,
    ENTITY_COUNT: 1
  }[sortConfigColumn]];
});

var availableMappings = {
  reverse: { DOWN: "asc", UP: "desc" },
  normal: { DOWN: "desc", UP: "asc" }
};
var mappingAssignments = {
  SPECIALTY: availableMappings.reverse,
  ENTITY_COUNT: availableMappings.normal
};
var sortByOrderDirection = function(sortConfig) {
  return mappingAssignments[sortConfig.column][sortConfig.order];
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
          options: [{key: 0, label: "All of Pathways"}].concat(
            _.sortBy(_.values(state.app.divisions).map((division) => {
              return {
                label: division.name,
                key: division.id
              };
            }), "label")
          )
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
  return _.chain(referents)
    .filter((referent) => {
      return _.includes(referent.specializationIds, specializationId);
    })
    .sortBy({clinics: "name", specialists: "lastName"}[collectionName])
    .map((referent) => {
      return {
        content: <a href={`/${collectionName}/${referent.id}`}>{referent.name}</a>,
        fadedContent: `Added: ${referent.createdAt}, Last Updated: ${referent.updatedAt}`,
        reactKey: referent.id
      };
    }).value();
};
