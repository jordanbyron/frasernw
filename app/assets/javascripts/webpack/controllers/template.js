import React from "react";
import Table from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { padTwo } from "utils";
import DateRangeFilters from "controllers/filter_groups/date_range";
import DivisionScopeFilters from "controllers/filter_groups/division_scope";
import { route } from "controller_helpers/routing";
import Breadcrumbs from "controllers/breadcrumbs";
import NavTabs from "controllers/nav_tabs";
import ReducedViewSelector from "controllers/reduced_view_selector";
import { reducedView, viewSelectorClass } from "controller_helpers/reduced_view";
import Sidebar from "controllers/sidebar";
import { recordShownByTab, isTabbedPage } from "controller_helpers/nav_tab_keys";
import { recordShownByRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import Subtitle from "controllers/subtitle";
import InlineArticles from "controllers/inline_articles";
import CategoryLinkController from "controllers/category_link"
import ResultSummary from "controllers/result_summary";
import { memoizePerRender } from "utils"
import SpecializationFilterMessage from "controllers/specialization_filter_message";
import CityFilterPills from "controllers/city_filter_pills";
import Lists from "controllers/lists";
import Disclaimer from "controllers/disclaimer";
import MainPanelAnnotation from "controllers/main_panel_annotation";
import pageTitleLabel from "controller_helpers/page_title_label";
import ShowHospital from "controllers/show_hospital";
import Pagination from "controllers/pagination";
import CustomWaittimeMessage from "controllers/custom_waittime_message";
import LoadingIndicator from "component_helpers/loading_indicator";

const Template = React.createClass({
  shouldComponentUpdate: function(nextProps) {
    let thisUi = this.props.model.ui;
    let nextUi = nextProps.model.ui;

    return nextUi.searchTerm === thisUi.searchTerm &&
      nextUi.selectedSearchResult === thisUi.selectedSearchResult &&
      nextUi.highlightSelectedSearchResult === thisUi.highlightSelectedSearchResult &&
      nextUi.searchTimerId === thisUi.searchTimerId;
  },
  render: function() {
    let model = this.props.model;
    let dispatch = this.props.dispatch;

    if(isLoaded(model)) {
      return(
        <div>
          <Breadcrumbs model={model} dispatch={dispatch}/>
          <UpperWhitePanel model={model}/>
          <NavTabs model={model} dispatch={dispatch}/>
          <LowerWhitePanel model={model} dispatch={dispatch}/>
        </div>
      );
    }
    else if (showsLowerPanel(model)) {
      return(<LoadingIndicator minHeight="300px"/>);
    }
    else {
      return(<noscript/>);
    }
  }
})


const isLoaded = (model) => {
  return model.app.currentUser && model.app.specialists;
}

const showInlineArticles = (model) => {
  return collectionShownName(model) === "contentItems" &&
    ((isTabbedPage(model) &&
      recordShownByTab(model).componentType === "InlineArticles") ||
    (!isTabbedPage(model) &&
      recordShownByRoute(model).componentType === "InlineArticles"))
};

const usesSidebarLayout = ((model) => {
  return (route === "/latest_updates" &&
    model.app.currentUser.role !== "user") ||
    (collectionShownName(model) === "contentItems" &&
      ((isTabbedPage(model) && recordShownByTab(model).filterable) ||
      (!isTabbedPage(model) && recordShownByRoute(model).filterable))) ||
    collectionShownName(model) === "specialists" ||
    collectionShownName(model) === "clinics" ||
    _.includes(["/reports/entity_page_views",
    "/reports/profiles_by_specialty",
    "/reports/page_views_by_user",
    "/issues"], route)
}).pwPipe(memoizePerRender)

const LowerWhitePanel = ({model, dispatch}) => {
  if (!showsLowerPanel(model)){
    return <noscript/>
  }
  else if (usesSidebarLayout(model)){
    return(
      <div className="content-wrapper">
        <div className="content">
          <ReducedViewSelector model={model} dispatch={dispatch}/>
          <div className="row">
            <div className={`span8half ${viewSelectorClass(model, "main")}`}>
              <Main model={model} dispatch={dispatch}/>
            </div>
            <Sidebar model={model} dispatch={dispatch}/>
          </div>
        </div>
      </div>
    );
  }
  else {
    return(
      <div className="content-wrapper">
        <div className="content">
          <div className="row">
            <div className="span12">
              <Main model={model} dispatch={dispatch}/>
            </div>
          </div>
        </div>
      </div>
    );
  }
};

const showsLowerPanel = (model) => {
  return !_.includes(RoutesWithoutLowerPanel, route);
}

const RoutesWithoutLowerPanel = [
  "/clinics/:id",
  "/specialists/:id",
  "/faq_categories/:id",
  "/referral_forms",
  "/content_items/:id",
  "/terms_and_conditions",
  "/"
];

const Main = ({model, dispatch}) => {
  return(
    <div>
      <LowerPanelTitle model={model}/>
      <Subtitle model={model} dispatch={dispatch}/>
      <ResultSummary model={model} dispatch={dispatch}/>
      <Disclaimer model={model}/>
      <SpecializationFilterMessage model={model} dispatch={dispatch}/>
      <CityFilterPills model={model} dispatch={dispatch}/>
      <CustomWaittimeMessage model={model} dispatch={dispatch}/>
      <Table model={model} dispatch={dispatch}/>
      <InlineArticles model={model} dispatch={dispatch}/>
      <Lists model={model} dispatch={dispatch}/>
      <CategoryLinkController model={model} dispatch={dispatch}/>
      <MainPanelAnnotation model={model} dispatch={dispatch}/>
      <Pagination model={model} dispatch={dispatch}/>
    </div>
  );
}

const UpperWhitePanel = ({model}) => {
  if(_.includes([
    "/hospitals/:id",
    "/languages/:id",
    "/news_items",
    "/issues",
    "/change_requests"
  ], route)){
    return(
      <div className="content-wrapper">
        <a href={window.location} style={{textDecoration: "none"}}>
          <h2 style={{marginBottom: "10px"}}>
            { pageTitleLabel(model) }
          </h2>
        </a>
        <ShowHospital model={model}/>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}


const LowerPanelTitle = ({model}) => {
  if(_.includes(["/reports/page_views_by_user",
    "/content_categories/:id",
    "/reports/profiles_by_specialty",
    "/latest_updates",
    "/reports/entity_page_views"
  ], route)) {
    return(
      <a href={window.location} style={{textDecoration: "none"}}>
        <h2 style={{marginBottom: "10px"}}>
          { pageTitleLabel(model) }
        </h2>
      </a>
    )
  }
  else {
    return <noscript/>
  }
}

export default Template;
