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

const NavTab = ({label, key, dispatch}) => {
  return(
    <li onClick={_.partial(key, dispatch)}
      key={index}
      className={this.className(tab.key)}
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
    return(
      <NavTab
        key={generatePanelKey("contentCategories", category.id)}
        label={category.name}
        dispatch={dispatch}
        selected={key === selectedPanelKey(model)}
      />
    );
  })
);

const selectedPanelKey = (model) => {
  return (model.ui.selectedPanel ||
    generatePanelKey(defaultPanel(model).type, defaultPanel(model).id));
};

const ConcreteNavTabs = ({model, dispatch}) {
  return(
    <NavTabs>
      <NavTab key="specialists" label="Specialists" dispatch={dispatch} selected={key === selectedPanelKey(model)}/>
      <NavTab key="clinics" label="Clinics" dispatch={dispatch} selected={key === selectedPanelKey(model)}/>
      {...contentCategoryTabs(model, dispatch)}
    </NavTabs>
  )
}

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

const filteredRecords =

const filteredRows =

const bodyRows = function(state, filtered, config, dispatch, sortConfig) => {
  var unsorted = filtered.map((row) => {
    return RowGenerators[config.rowGenerator](state.app, dispatch, config.rowGeneratorConfig, row);
  });

  return _.sortByOrder(
    unsorted,
    sortFunctions[config.panelTypeKey](sortConfig, state.app.currentUser.cityRankings, state.app.currentUser.cityRankingsCustomized),
    sortOrders[config.panelTypeKey](sortConfig, state.app.currentUser.cityRankingsCustomized)
  );
};

const resultSummaryText =

const userDefinedFilterValues = (model) => {
  return _.get(model, ["ui", "panels", selectedPanelTypeKey(model), "filterValues"], {});
};

var opaqueFiltered = (model) {
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

const opaqueFiltered = (model) => {
  _.values(state.app[panelTypeKey]),
  panelTypeKey,
  filterValues,
  { userIsAdmin: state.app.currentUser.isAdmin }
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
          <ConcreteTable model={model} dispatch={dispatch}/>
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
