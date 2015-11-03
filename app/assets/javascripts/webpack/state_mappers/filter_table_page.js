var _ = require("lodash");
var Filters = require("./filter_table/filters");
var RowGenerators = require("./filter_table/row_generators");
var FILTER_VALUE_GENERATORS = require("./filter_table/filter_value_generators");
var FILTER_GROUP_GENERATORS = require("./filter_table/filter_group_generators");
var sortFunctions = require("./filter_table/sort_functions");
var sortOrders = require("./filter_table/sort_orders");
var generateResultSummary = require("./filter_table/generate_result_summary");
var referralCities = require("./filter_table/referral_cities");
var utils = require("utils");

module.exports = function(state, dispatch, config) {
  // console.log("STATE:");
  // console.log(state);

  if (state.ui.hasBeenInitialized) {
    return {
      selectedPanel: selectedPanel(state, dispatch), // specifies what panel (i.e. top menu bar tab) is selected
      isLoading: false,
      tabs: tabs(state),
      dispatch: dispatch,
      feedbackModal: feedbackModal(state)
    };
  } else {
    return {
      isLoading: true,
      dispatch: dispatch,
      feedbackModal: { state: "HIDDEN" }
    };
  }
}

var feedbackModal = function(state) {
  return (state.ui.feedbackModal || { state: "HIDDEN"});
}

var selectedPanel = function(state, dispatch) {
  var defaultPanel =
    state.app.divisions[state.app.currentUser.divisionIds[0]].openToSpecializationPanel[state.ui.specializationId];
  var selectedPanelKey = (state.ui.selectedPanel || generatePanelKey(defaultPanel.type, defaultPanel.id));
  var selectedPanelType = panelTypeKey(selectedPanelKey);

  return PANEL_GENERATORS[selectedPanelType](state, dispatch, selectedPanelKey);
}

var generatePanelKey = function(type, id) {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
}
var panelTypeKey = function(panelKey) {
  return panelKey.replace(/[0-9]/g, '');
}

var panelRecordId = function(panelKey) {
  return panelKey.match(/\d/g).join("");
}

var tabs = function(state) {
  return [
    { key: "specialists", label: "Specialists" },
    { key: "clinics", label: "Clinics" },
  ].concat(contentCategoryTabs(state))
}

var contentCategoryTabs = function(state) {
  return _.values(
    findActiveContentCategories(state)
  ).map((category) => {
    return { key: generatePanelKey("contentCategories", category.id), label: category.name };
  });
}

var PANEL_GENERATORS = {
  specialists: function(state, dispatch, panelKey) {
    return {
      key: panelKey,
      contentComponent: "FilterTable",
      contentComponentProps: PANEL_PROPS_GENERATORS["specialists"](state, dispatch),
    };
  },
  clinics: function(state, dispatch, panelKey) {
    return {
      key: panelKey,
      contentComponent: "FilterTable",
      contentComponentProps: PANEL_PROPS_GENERATORS["clinics"](state, dispatch)
    };
  },
  contentCategories: function(state, dispatch, panelKey) { //i.e. physician resources, pearls, etc.
    var category = state.app.contentCategories[panelRecordId(panelKey)];

    return {
      key: panelKey,
      contentComponent: category.componentType,
      contentComponentProps: PANEL_PROPS_GENERATORS["contentCategories"][category.componentType](state, panelKey, category, dispatch)
    };
  }
}
var opaqueFiltered = function(referents: Array, panelTypeKey: string, filterValues: Object, config: Object) {
  var operativeOpaqueFilters = _.values(_.pick(Filters, PANEL_TYPE_OPAQUE_FILTERS[panelTypeKey])).filter(
    function(predicate: Object): boolean {
      return  predicate.isActivated(filterValues);
    }
  );

  return referents.filter((row) => {
    return _.every(
      operativeOpaqueFilters,
      (filter) => filter.predicate(row, filterValues, config.userIsAdmin)
    );
  });
};

var filterByPageType = function(records, state) {
  return {
    specialization() {
      return records.filter((record) => {
        return _.includes(record.specializationIds, state.ui.specializationId);
      });
    },
    procedure() {
      return records.filter((record) => {
        return (_.includes(record.procedureIds, state.ui.procedureId));
      });
    },
  }[state.ui.pageType]();
};

var filterByCities = function(set, filterValues){
  return set.filter((record) => {
    return record.cityIds.some((id) => filterValues.cities[id]);
  });
};

var anyFiltersActivated = function(filterValueOverrides) {
  return !_.every(_.values(filterValueOverrides), (filterValue) => {
    return (filterValue === undefined ||
      !_.any(_.values(filterValue)))
  });
};

var finalSet = function(filtered, filterValues, pageType, filterValueOverrides) {
  if (shouldIncludeOtherSpecializations(filtered, filterValues, pageType, filterValueOverrides) && pageType === "specialization"){
    return filtered.withoutPageTypeFilter;
  }
  else {
    return filtered.withAllFilters;
  }
};

var shouldIncludeOtherSpecializations = function(filtered, filterValues, pageType, filterValueOverrides) {
  return (pageType !== "specialization" ||
    (shouldShowSpecializationFilter(filtered, filterValues, pageType, filterValueOverrides) &&
      !filterValues.specializationFilterActivated));
};

var shouldShowCityFilterMessage = function(filtered, filterValues, pageType) {
  return (filtered.withAllFilters.length === 0 &&
    ((pageType !== "specialization") ||
      (filtered.withoutPageTypeFilter.length === 0)));
};

var shouldShowSpecializationFilter = function(filtered, filterValues, pageType, filterValueOverrides) {
  return ((pageType === "specialization") &&
    ((
      (filtered.withAllFilters.length > 0) &&
      (_.values(_.pick(filterValues.procedures, _.identity)).length > 0) &&
      (filtered.withoutPageTypeFilter.length > filtered.withAllFilters.length)
    ) ||
    (
      (filtered.withAllFilters.length === 0) &&
      (filtered.withoutPageTypeFilter.length > 0) &&
      (anyFiltersActivated(filterValueOverrides))
    ))
  );
};

var PANEL_PROPS_GENERATORS = {
  specialists: function(state, dispatch) {
    return this.referents(state, dispatch, "specialists");
  },
  clinics: function(state, dispatch) {
    return this.referents(state, dispatch, "clinics");
  },
  referents: function(state, dispatch, panelTypeKey) {
    // what are the records we're using to mask filters?
    var maskingSet = {
      specialization: function() {
        return _.values(state.app[panelTypeKey]).filter((record) => {
          return _.includes(record.specializationIds, state.ui.specializationId);
        });
      },
      procedure: function() {
        return _.values(state.app[panelTypeKey]).filter((record) => {
          return _.includes(record.procedureIds, state.ui.procedureId);
        });
      }
    }[state.ui.pageType]();

    var sortConfig = referentSortConfig(state, { panelTypeKey: panelTypeKey });
    var filterValues = generateFilterValuesForPanel(
      state,
      maskingSet,
      {
        panelKey: panelTypeKey,
        panelTypeKey: panelTypeKey
      }
    );
    var _filterValueOverrides = _.get(state, ["ui", "panels", panelTypeKey, "filterValues"], {});
    var _opaqueFiltered = opaqueFiltered(
      _.values(state.app[panelTypeKey]),
      panelTypeKey,
      filterValues,
      { userIsAdmin: state.app.currentUser.isAdmin }
    );
    var filtered = {
      withAllFilters: utils.from(
        _.partialRight(filterByPageType, state),
        _.partialRight(filterByCities, filterValues),
        _opaqueFiltered
      ),
      withoutPageTypeFilter: filterByCities(_opaqueFiltered, filterValues),
      withoutCityFilter: filterByPageType(_opaqueFiltered, state)
    };

    var bodyRowConfig = {
      panelTypeKey: panelTypeKey,
      panelKey: state.ui.panelTypeKey,
      rowGenerator: "referents",
      rowGeneratorConfig: {
        includingOtherSpecialties: shouldIncludeOtherSpecializations(filtered, filterValues, state.ui.pageType, _filterValueOverrides)
      }
    };
    var bodyRows = generateBodyRows(
      state,
      finalSet(filtered, filterValues, state.ui.pageType, _filterValueOverrides),
      bodyRowConfig,
      dispatch,
      sortConfig
    );
    var memberName = {
      specialists: state.app.specializations[state.ui.specializationId].memberName,
      clinics: "Clinic"
    }[panelTypeKey];
    var genericMembersName = {
      specialists: "specialists",
      clinics: "Clinics"
    }[panelTypeKey];
    var membersName = {
      specialists: (state.ui.pageType == "specialization" ? state.app.specializations[state.ui.specializationId].membersName : "Specialists"),
      clinics: "Clinics"
    }[panelTypeKey];
    var resultSummaryText = generateResultSummary({
      app: state.app,
      bodyRows: bodyRows,
      labelName: genericMembersName,
      panelTypeKey: panelTypeKey,
      referralCities: referralCities(state),
      filterValues: filterValues,
      availableFilters: PANEL_TYPE_SUMMARY_FILTERS[panelTypeKey]
    });
    var specializationRemainderCount =
      filtered.withoutPageTypeFilter.length - filtered.withAllFilters.length;
    var availableFromOtherCities = _.difference(
      filtered.withoutCityFilter,
      filtered.withAllFilters
    );


    // sort config - sort arrow on table
    return {
      // TODO name this 'tableHeadings'
      headings: TABLE_HEADINGS_GENERATORS.referents(
        memberName,
        shouldIncludeOtherSpecializations(filtered, filterValues, state.ui.pageType, _filterValueOverrides)
      ),
      bodyRows: bodyRows,
      resultSummary: {
        anyResults: (bodyRows.length > 0),
        isVisible: (resultSummaryText.length > 1),
        text: resultSummaryText,
        showClearButton: anyFiltersActivated(_filterValueOverrides)
      },
      cityFilterPills: {
        shouldDisplay: shouldShowCityFilterMessage(filtered, filterValues, state.ui.pageType),
        availableFromOtherCities: availableFromOtherCities,
        cityFilterValues: filterValues.cities,
        cities: state.app.cities
      },
      specializationFilterMessage: {
        shouldDisplay: shouldShowSpecializationFilter(filtered, filterValues, state.ui.pageType, _filterValueOverrides),
        remainderCount: specializationRemainderCount,
        dispatch: dispatch,
        collectionName: genericMembersName,
        showingOtherSpecialties: !filterValues.specializationFilterActivated
      },
      assumedList: assumedListProps(state, panelTypeKey, membersName),
      iconKey: panelTypeKey,
      reducedView: _.get(state, ["ui", "panels", panelTypeKey, "reducedView"], "main"),
      sortConfig: sortConfig,
      // TODO name this 'sidebarFilteringSection'
      filters: {
        title: ("Filter " + membersName),
        // TODO: name this 'sidebarFilteringSectionGroups'
        groups: generateFilterGroups(
          maskingSet,
          state,
          {
            panelTypeKey: panelTypeKey,
            panelKey: panelTypeKey
          }
        )
      }
    };
  },
  contentCategories: {
    FilterTable: function(state: Object, panelKey: string, category: Object, dispatch: Function) {
      var forCategory = itemsForContentCategory(category, state);
      var maskingSet = forCategory;
      var bodyRowConfig = {
        panelKey: panelKey,
        panelTypeKey: "contentCategories",
        rowGenerator: "resources",
        rowGeneratorConfig: {
          panelKey: panelKey
        }
      };
      var sortConfig = generateSortConfig(state, { panelKey: panelKey, defaultConfig: { column: "TITLE", order: "DOWN" }});
      var filterValues = generateFilterValuesForPanel(
        state,
        maskingSet,
        {
          panelKey: panelKey,
          panelTypeKey: "contentCategories"
        }
      );
      var filtered = filterResources(forCategory, filterValues, state.app.currentUser.isAdmin)
      var bodyRows = generateBodyRows(state, filtered, bodyRowConfig, dispatch, sortConfig);
      var resultSummaryText = generateResultSummary({
        app: state.app,
        bodyRows: bodyRows,
        labelName: category.name.toLowerCase(),
        panelTypeKey: "contentCategories",
        referralCities: referralCities(state),
        filterValues: filterValues,
        availableFilters: PANEL_TYPE_SUMMARY_FILTERS["contentCategories"]
      });

      return {
        headings: TABLE_HEADINGS_GENERATORS["contentCategories"](),
        bodyRows: bodyRows,
        sortConfig: sortConfig,
        resultSummary: {
          anyResults: (bodyRows.length > 0),
          isVisible: (resultSummaryText.length > 1),
          text: resultSummaryText,
          showClearButton: true
        },
        cityFilterPills: {
          shouldDisplay: false
        },
        specializationFilterMessage: {
          shouldDisplay: false
        },
        assumedList: {
          shouldDisplay: false
        },
        iconKey: false,
        reducedView: _.get(state, ["ui", "panels", panelKey, "reducedView"], "main"),
        filters: {
          title: ("Filter " + category.name),
          groups: generateFilterGroups(
            maskingSet,
            state,
            {
              panelTypeKey: "contentCategories",
              panelKey: panelKey
            }
          )
        }
      };
    },
    InlineArticles: function(state: Object, panelKey: string, category: Object, dispatch: Function) {
      var records = itemsForContentCategory(category, state);

      return {
        panelKey: panelKey,
        records: records,
        categoryLink: {
          link: ("/content_categories/" + category.id),
          text: ("Browse " + category.name + " content from all specialties")
        },
        favorites: state.app.currentUser.favorites
      };
    }
  }
}

var filterResources = function(rows, filterValues, userIsAdmin) {
  var operativeOpaqueFilters = _.values(_.pick(Filters, PANEL_TYPE_OPAQUE_FILTERS["contentCategories"])).filter(
    function(predicate: Object): boolean {
      return  predicate.isActivated(filterValues);
    }
  );

  return rows.filter((row) => {
    return _.every(
      operativeOpaqueFilters,
      (filter) => filter.predicate(row, filterValues, userIsAdmin)
    );
  });
}

var assumedListProps = function(state: Object, panelTypeKey: string, membersName: string): Object {
  var list = labeledAssumedList(
    state.app.specializations[state.ui.specializationId].nestedProcedureIds,
    state.app.procedures,
    panelTypeKey
  );

  return {
    shouldDisplay: list.length > 0,
    list: list,
    membersName: (panelTypeKey === "specialists" ? membersName : `${state.app.specializations[state.ui.specializationId].name} Clinics`)
  };
}

var labeledAssumedList = function(nestedProcedures: Object, normalizedProcedures: Object, collectionName: string): Array {
  return _.chain(createAssumedList(nestedProcedures, collectionName))
    .map((id) => normalizedProcedures[id].name.toLowerCase())
    .sortBy(_.identity)
    .value()
}

var createAssumedList = function(nestedProcedures: Object, collectionName: string): Array {
  return _.chain(nestedProcedures)
    .pick((procedure, id) => procedure.assumed[collectionName])
    .keys()
    .concat(..._.flatten(_.values(nestedProcedures).map((procedure) => createAssumedList(procedure.children, collectionName))))
    .uniq()
    .value()
}


var generateBodyRows = function(state: Object, filtered: Array, config: Object, dispatch: Function, sortConfig: Object): Array {
  var unsorted = filtered.map((row) => {
    return RowGenerators[config.rowGenerator](row, state.app, dispatch, config.rowGeneratorConfig);
  });

  return _.sortByOrder(
    unsorted,
    sortFunctions[config.panelTypeKey](sortConfig, state.app.currentUser.cityRankings),
    sortOrders[config.panelTypeKey](sortConfig)
  );
}

// OPAQUE = we don't see the number of results we could have if we configure
// the filter differently
var PANEL_TYPE_OPAQUE_FILTERS = {
  specialists: [
    "procedures",
    "acceptsReferralsViaPhone",
    "patientsCanBook",
    "respondsWithin",
    "sexes",
    "scheduleDays",
    "interpreterAvailable",
    "languages",
    "clinicAssociations",
    "hospitalAssociations",
  ],
  clinics: [
    "procedures",
    "scheduleDays",
    "languages",
    "public",
    "private",
    "wheelchairAccessible",
    "careProviders"
  ],
  contentCategories: [
    "subcategories"
  ]
};
// all filters that are used for the panel
var PANEL_TYPE_FILTERS = {
  specialists: PANEL_TYPE_OPAQUE_FILTERS["specialists"].concat(["cities", "specializationFilterActivated"]),
  clinics: PANEL_TYPE_OPAQUE_FILTERS["clinics"].concat(["cities", "specializationFilterActivated"]),
  contentCategories: PANEL_TYPE_OPAQUE_FILTERS["contentCategories"]
};
var PANEL_TYPE_SUMMARY_FILTERS = PANEL_TYPE_FILTERS;
var PANEL_TYPE_FILTER_GROUPS = {
  specialists: ["procedures", "referrals", "sexes", "scheduleDays", "languages", "associations", "cities"],
  clinics: ["procedures", "clinicDetails", "scheduleDays", "careProviders", "languages", "cities"],
  contentCategories: ["subcategories"]
};

var generateFilterValuesForPanel = function(state, maskingSet, config) {
  return _.chain(FILTER_VALUE_GENERATORS)
    .pick(PANEL_TYPE_FILTERS[config.panelTypeKey])
    .mapValues((generator) => generator(state, maskingSet, config.panelKey))
    .value();
}

var generateFilterGroups = function(maskingSet, state, config) {
  return PANEL_TYPE_FILTER_GROUPS[config.panelTypeKey].map((groupKey) => {
    return FILTER_GROUP_GENERATORS[groupKey](config.panelKey, maskingSet, state);
  });
}

var generateSortConfig = function(state, functionConfig) {
  return _.assign(
    {},
    functionConfig.defaultConfig,
    _.get(state, ["ui", "panels", functionConfig.panelKey, "sortConfig"], {})
  );
}

var referentSortConfig = function(state, config) {
  return generateSortConfig(
    state,
    {
      panelKey: config.panelTypeKey,
      defaultConfig: {
        column: "REFERRALS",
        order: "DOWN"
      }
    }
  );
};

var TABLE_HEADINGS_GENERATORS = {
  contentCategories: function() {
    return [
      { label: "Title", key: "TITLE" },
      { label: "Category", key: "SUBCATEGORY" },
      { label: "", key: "FAVOURITE" },
      { label: "", key: "EMAIL_TO_PATIENT" },
      { label: "", key: "PROVIDE_FEEDBACK" }
    ];
  },
  referents: function(labelName, includingOtherSpecializations, pageType) {
    if (includingOtherSpecializations) {
      return [
        { label: labelName, key: "NAME", className: "specialization_table__th--name" },
        { label: "Specialties", key: "SPECIALTIES", className: "specialization_table__th--specialties" },
        { label: "Accepting New Referrals?", key: "REFERRALS", className: "specialization_table__th--referrals" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME", className: "specialization_table__th--waittime" },
        { label: "City", key: "CITY", className: "specialization_table__th--city" }
      ];
    } else {
      return [
        { label: labelName, key: "NAME", className: "specialization_table__th--name" },
        { label: "Accepting New Referrals?", key: "REFERRALS", className: "specialization_table__th--referrals" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME", className: "specialization_table__th--waittime" },
        { label: "City", key: "CITY", className: "specialization_table__th--city" }
      ];
    }
  }
}

var itemsForContentCategory = function(category, state) {
  var pageSpecificFilter = {
    specialization: function(contentItem) {
      return _.includes(contentItem.specializationIds, state.ui.specializationId);
    },
    procedure: function(contentItem) {
      return _.includes(contentItem.specializationIds, state.ui.specializationId);
    }
  }

  return _.chain(state.app.contentItems)
    .values()
    .filter((contentItem) => {
      return (pageSpecificFilter[state.ui.pageType](contentItem) &&
        _.any(_.intersection(contentItem.availableToDivisionIds, state.app.currentUser.divisionIds)) &&
        _.includes(category.subtreeIds, contentItem.categoryId));
    })
    .value();
};

var findActiveContentCategories = function(state) {
  return _.filter(
    state.app.contentCategories,
    (category) => {
      return ([1, 3, 4, 5].indexOf(category.displayMask) > -1 &&
        category.ancestry == null &&
        _.keys(itemsForContentCategory(category, state)).length > 0);
    }
  );
};
