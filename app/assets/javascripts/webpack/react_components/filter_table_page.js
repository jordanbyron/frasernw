var React = require("react");
var LoadingContainer = require("./loading_container");
var Panels = require("./panels");
var FeedbackModal = require("./feedback_modal");
import anyFiltersActivated from "state_mappers/filter_table/any_filters_activated";

const isLoading = (model) => model.ui.hasBeenInitialized;

const feedbackModalConfig = (model) => {
  return model.ui.feedbackModal || { state: "HIDDEN"};
};

var defaultPanel = function(model) {
  return {
    specialization: function() {
      const determiningDivision = model.app.divisions[model.app.currentUser.divisionIds[0]]

      return determiningDivision.openToSpecializationPanel[model.ui.specializationId];
    },
    procedure: function() { return { type: "specialists" } },
  }[model.ui.pageType]();
}

const NavTabs = ({children}) => {
  return(
    <ul className="nav nav-tabs">
      { children }
    </ul>
  )
};

const onTabClick = function(key, dispatch, event) {
  dispatch({
    type: "SELECT_PANEL",
    panel: key
  })
};

const NavTab = ({label, onClick, isSelected}) => {
  const className = isSelected ? "active" : ""

  return(
    <li onClick={_.partial(key, dispatch)}
      className={className}
    >
      <a>{ tab.label }</a>
    </li>
  );
};

const activeContentCategories = (model) => {
  return _.filter(
    model.app.contentCategories,
    (category) => {
      return ([1, 3, 4, 5].indexOf(category.displayMask) > -1 &&
        category.ancestry == null &&
        _.keys(itemsForContentCategory(category.id, model, model.app.currentUser.divisionIds)).length > 0);
    }
  );
}

const contentCategoryTabs = (model, dispatch) =>
  return _.values(activeContentCategories(model)).map((category) => {
    const _key = generatePanelKey("contentCategories", category.id)

    return(
      <NavTab
        label={category.name}
        onClick={_.partial(onTabClick, _key, dispatch)}
        selected={_key === selectedPanelKey(model)}
      />
    );
  })
);

const selectedPanelKey = (model) => {
  return (model.ui.selectedPanel ||
    generatePanelKey(defaultPanel(model).type, defaultPanel(model).id));
};

const panelRecordId = function(panelKey) {
  return panelKey.match(/\d/g).join("");
}

const selectedPanelComponent = createSelector(
  selectedPanelKey,
  (model) => model.app.contentCategories,
  (selectedPanelKey, contentCategories) => {
    if (_.includes(["specialists", "clinics"], selectedPanelKey)) {
      return FilterTable;
    } else {
      return contentCategories[panelRecordId(panelKey)].componentType;
    }
  }
)

const SelectedPanel = ({model, dispatch}) => {
  return React.createElement(
    COMPONENTS[this.props.selectedPanel.contentComponent],
    {
      model: model,
      dispatch: dispatch
    }
  );
};

const filterByCities = function(records, filterValues){
  return records.filter((record) => {
    return record.cityIds.some((id) => filterValues.cities[id]);
  });
};

const filterByPageType = (records, model, selectedPanelTypeKey) => {
  return {
    specialization() {
      return records.filter((record) => {
        return _.includes(record.specializationIds, model.ui.specializationId);
      });
    },
    procedure() {
      var assumedSpecializationIds =
        model.app.procedures[model.ui.procedureId].assumedSpecializationIds[panelTypeKey];

      return records.filter((record) => {
        return (_.includes(record.procedureIds, model.ui.procedureId) ||
          _.any(_.intersection(record.specializationIds, assumedSpecializationIds)));
      });
    },
  }[model.ui.pageType]();
};

const filteredWithoutCityFilter = createSelector(
  opaqueFiltered,
  (model) => model,
  selectedPanelTypeKey,
  (opaqueFiltered, filterValues, selectedPanelTypeKey) => {
    return filterByPageType(opaqueFiltered, model, selectedPanelTypeKey);
  }
)

const filteredWithoutPageTypeFilter = createSelector(
  opaqueFiltered,
  filterValues,
  (opaqueFiltered, filterValues) => {
    return filterByCities(opaqueFiltered, filterValues);
  }
);

const filteredWithAllFilters = createSelector(
  opaqueFiltered,
  selectedPanelTypeKey,
  filterValues,
  (opaqueFiltered, selectedPanelTypeKey, filterValues) => {
    return utils.from(
      _.partialRight(filterByPageType, state, selectedPanelTypeKey),
      _.partialRight(filterByCities, filterValues),
      _opaqueFiltered
    );
  }
)

const isAdmin = (model) => model.app.currentUser.isAdmin

const operativeOpaqueFilters = createSelector(
  selectedPanelTypeKey,
  (selectedPanelTypeKey) => {
    return _.values(_.pick(Filters, PANEL_TYPE_OPAQUE_FILTERS[panelTypeKey])).filter(
      (predicate) => {
        return  predicate.isActivated(filterValues);
      }
    );
  }
)

const filterValues = createSelector(
  (model) => model,
  filterMaskingSet,
  selectedPanelKey,
  selectedPanelTypeKey,
  (model, filterMaskingSet, selectedPanelKey, selectedPanelTypeKey) => {
    return _.chain(FILTER_VALUE_GENERATORS)
      .pick(PANEL_TYPE_FILTERS[selectedPanelTypeKey])
      .mapValues((generator) => generator(model, filterMaskingSet, selectedPanelKey))
      .value();
  }
);

const panelCollection = createSelector(
  selectedPanelTypeKey,
  (model) => model.app,
  (selectedPanelTypeKey, app) => app[selectedPanelTypeKey]
);

const opaqueFiltered = createSelector(
  panelCollection,
  operativeOpaqueFilters,
  isAdmin,
  filterValues,
  (panelCollection, operativeOpaqueFilters, isAdmin, filterValues) => {
    return panelCollection.filter((record) => {
      return _.every(
        operativeOpaqueFilters,
        (filter) => filter.predicate(record, filterValues, isAdmin)
      );
    });
  }
);

const recordsToDisplay = createSelector(
  shouldIncludeOtherSpecializations,
  pageType,
  (shouldIncludeOtherSpecializations, pageType) => {
    if (shouldIncludeOtherSpecializations) {
      return filteredWithoutPageTypeFilter;
    }
    else {
      return filteredWithAllFilters;
    }
  }
);

const filterMaskingSet = createSelector(
  selectedPanelTypeKey,
  (model) => model,
  (selectedPanelTypeKey, model) => {
    return filterByPageType(_.values(model.app[panelTypeKey]), model, panelTypeKey);
  }
);

const rowGeneratorKey = createSelector(
  selectedPanelTypeKey,
  (selectedPanelTypeKey) => {
    if (_.includes(["specialists", "clinics"], selectedPanelTypeKey)){
      return "referents"
    }
    else {
      return "resources"
    }
  }
);

const activatedProcedureFilters = createSelector(
  filterValues,
  (filterValues) => {
    return _.keys(_.pick(filterValues.procedures, _.identity));
  }
);

const customWaittimeConfig = createSelector(
  activatedProcedureFilters,
  model,
  selectedPanelTypeKey,
  (activatedProcedureFilters, model, panelTypeKey) => {
    if(model.ui.pageType === "specialization") {
      let nestedProcedureIds = model.app.specializations[model.ui.specializationId].nestedProcedureIds

      return {
        shouldUse: (activatedProcedureFilters.length === 1 &&
          nestedProcedureIds[activatedProcedureFilters[0]].customWaittime[panelTypeKey]),
        procedureId: activatedProcedureFilters[0]
      };
    }
    else if(model.ui.pageType === "procedure") {
      let sources = {
        page: {
          test: (model.app.procedures[model.ui.procedureId].customWaittime[panelTypeKey] &&
            activatedProcedureFilters.length === 0),
          id: model.ui.procedureId
        },
        selection: {
          test: (!model.app.procedures[model.ui.procedureId].customWaittime[panelTypeKey] &&
            activatedProcedureFilters.length === 1 &&
            model.app.procedures[activatedProcedureFilters[0]].customWaittime[panelTypeKey]),
          id: activatedProcedureFilters[0]
        }
      }

      return {
        shouldUse: _.some(sources, _.property("test")),
        procedureId: (_.find(sources, _.property("test")) || {}).id
      }
    }
  };
);

const tableRowContents = (model, dispatch) => {
  const rowGeneratorConfig = {
    includingOtherSpecialties: shouldIncludeOtherSpecializations(model),
    customWaittime: customWaittimeConfig(model)
  }

  return recordsToDisplay(model).map((record) => {
    return RowGenerators[rowGeneratorKey(model)](
      state.app,
      dispatch,
      rowGeneratorConfig,
      record
    );
  });
};

const userDefinedSortConfig = createSelector(
  selectedPanelKey,
  (model) => model,
  (selectedPanelKey) => {
    return _.get(state, ["ui", "panels", functionConfig.panelKey, "sortConfig"], {});
  }
);

const cityRankings = (model) => model.app.currentUser.cityRankings
const areCityRankingsCustomized = (model) => model.app.currentUser.cityRankingsCustomized

const sortConfig = createSelector(
  defaultSortColumn,
  userDefinedSortConfig,
  cityRankings,
  areCityRankingsCustomized,
  (defaultSortColumn, userDefinedSortConfig) => {
    return _.assign(
      {
        column: defaultSortColumn,
        order: defaultSortOrder,
        cityRankings: cityRankings,
        areCityRankingsCustomized: areCityRankingsCustomized
      },
      userDefinedSortConfig
    );
  }
);

const defaultSortColumn = createSelector(
  selectedPanelTypeKey,
  (selectedPanelTypeKey) => {
    if (_.includes(["specialists", "clinics"], selectedPanelTypeKey)) {
      return "REFERRALS"
    }
    else {
      return "TITLE"
    }
  }
);
const defaultSortOrder = "DOWN";

const sortedTableRowContents = (model, dispatch) => {
  return _.sortByOrder(
    tableRowContents(model, dispatch),
    sortByOrderFunctions[selectedPanelTypeKey(model)](sortConfig(model)),
    sortByOrderOrders[selectedPanelTypeKey(model)](sortConfig(model))
  );
};

const userDefinedFilterValues = (model) => {
  return _.get(model, ["ui", "panels", selectedPanelTypeKey(model), "filterValues"], {});
};

const ConcreteResultSummary = ({model, dispatch}) => {
  return(
    <ResultSummary
      anyResults={filteredRecords(model).length > 0}
      isVisible={resultsSummaryText(model).length > 0}
      text={resultSummaryText(model)}
      showClearButton={anyFiltersActivated(model)}
    />
  );
};

const Header = ({model, dispatch}) => {
  return(
    <div>
      <ConcreteResultSummary model={model} dispatch={dispatch}/>
      <CustomizedWaittimeMessage model={model} dispatch={dispatch}/>
      <AssumedMessage model={model} dispatch={dispatch}/>
      <SpecializationFilterMessage model={model} dispatch={dispatch}/>
      <CityFilterPills model={model} dispatch={dispatch}/>
    </div>
  );
};

// TODO: implement TableHeading

const tableHeadings = (model, dispatch) => {
  return
}

const selectedPanelTypeKey = createSelector(
  selectedPanelKey,
  (selectedPanelKey) => panelKey.replace(/[0-9]/g, '')
);

const reducedView = (model) => {
  return _.get(
    model,
    ["ui", "panels", selectedPanelTypeKey(model), "reducedView"],
    "main"
  );
};

const labelName = (model) => {
  // TODO
}

const tableHeadingContents = createSelector(
  labelName,
  shouldIncludeOtherSpecializations,
  selectedPanelType,
  (labelName, shouldIncludeOtherSpecializations, selectedPanelType) => {
    if (_.includes(["specialists", "clinics"], selectedPanelType)) {
      return TABLE_HEADING_GENERATORS.referents(labelName, shouldIncludeOtherSpecializations);
    }
    else {
      return TABLE_HEADINGS_GENERATORS.contentCategories();
    }
  }
);

const onHeadingClick = (dispatch, key, currentOrder, currentColumn) => {
  return dispatch({
    type: "TOGGLE_ORDER_BY_COLUMN",
    headerKey: key,
    currentColumn: this.props.sortConfig.column,
    currentOrder: this.props.sortConfig.order
  });
},

const tableHeadings = ({model, dispatch}) => {
  tableHeadingContents(model).map((cell, index) => {
    const onClick = _.partial(
      onHeadingClick,
      dispatch,
      cell.key,
      sortConfig(model).column,
      sortConfig(model).order
    )

    return(
      <TableHeading
        key={index}
        showArrow={key == sortConfig(model).column}
        arrowDirection={}
        className={cell.className}
        onClick={onClick}
        label={cell.label}
      />
    );
  })
}

const tableRows = (model, dispatch) => {
  return sortedTableRowContents(model, dispatch).map((row) => {
    return(
      <TableRow key={row.reactKey}>
        {
          row.cells.map((cell, index) => {
            return(<TableCell key={index}>{ cell }</TableCell>);
          })
        }
      </TableRow>
    )
  })
};

const FilterTable = ({model, dispatch}) => {
  return(
    <div>
      <ReducedViewSelector
        dispatch={dispatch}
        reducedView={reducedView(model)}
      />
      <SidebarLayout>
        <Main>
          <Header model={model} dispatch={dispatch}/>
          <Table>
            <thead>
              <tr>
                {...tableHeadings(model, dispatch)}
              </tr>
            </thead>
            <tbody>
              {...tableRows(model, dispatch)}
            </tbody>
          </Table>
          <Footer model={model} dispatch={dispatch}/>
        </Main>
        <Side>
          <Filters model={model} dispatch={dispatch}/>
        </Side>
      </SidebarLayout>
    </div>
  );
}

const Contents = ({model, dispatch}) => {
  return(
    <div>
      <ConcreteNavTabs model={model} dispatch={dispatch}/>
      <SelectedPanel model={model} dispatch={dispatch}/>
    </div>
  );
};

const FilterTablePage = (props) => {
  return(
    <div>
      <LoadingContainer isLoading={isLoading(props.model)}
        renderContents={Contents.bind(null, props)}
        minHeight={"300px"}
      />
      <FeedbackModal
        dispatch={props.dispatch}
        {...feedbackModalConfig(props.model)}
      />
    </div>
  );
})
