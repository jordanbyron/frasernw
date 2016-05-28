import React from "react";
import Table from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";
import DateRangeFilters from "controllers/filter_groups/date_range";
import DivisionScopeFilters from "controllers/filter_groups/division_scope";
import { matchedRoute } from "controller_helpers/routing";
import Breadcrumbs from "controllers/breadcrumbs";
import NavTabs from "controllers/nav_tabs";
import ReducedViewSelector from "controllers/reduced_view_selector";
import { reducedView, viewSelectorClass } from "controller_helpers/reduced_view";
import Sidebar from "controllers/sidebar";
import { recordShownByTab, isTabbedPage } from "controller_helpers/tab_keys";
import { recordShownByPage } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import PageTitle from "controllers/page_title";
import Subtitle from "controllers/subtitle";
import InlineArticles from "controllers/inline_articles";
import CategoryLinkController from "controllers/category_link"
import ResultSummary from "controllers/result_summary";

const Template = ({model, dispatch}) => {
  if(isLoaded(model)) {
    return(
      <div>
        <Breadcrumbs model={model} dispatch={dispatch}/>
        <NavTabs model={model} dispatch={dispatch}/>
        <WhitePanel model={model} dispatch={dispatch}/>
      </div>
    );
  }
  else {
    return(<span></span>);
  }
};

const isLoaded = (model) => {
  switch(matchedRoute(model)){
    case "/specialties/:id":
      return model.app.specialists && model.app.currentUser;
    case "/areas_of_practice/:id":
      return model.app.specialists && model.app.currentUser;
    case "/content_categories/:id":
      return model.app.specialists && model.app.currentUser;
    case "/latest_updates":
      return model.app.currentUser;
    case "/reports/pageviews_by_user":
      return model.app.currentUser;
    case "/reports/referents_by_specialty":
      return model.app.currentUser;
    case "/reports/usage":
      return model.app.currentUser;
    default:
      return true;
  }
}

const showInlineArticles = (model) => {
  return collectionShownName(model) === "contentItems" &&
    ((isTabbedPage(model) &&
      recordShownByTab(model).componentType === "InlineArticles") ||
    (!isTabbedPage(model) &&
      recordShownByPage(model).componentType === "InlineArticles"))
};

const usesSidebarLayout = (model) => {
  return !((matchedRoute(model) === "/latest_updates" &&
    model.app.currentUser.role === "admin") ||
    showInlineArticles(model))
}

const WhitePanel = ({model, dispatch}) => {
  if (usesSidebarLayout(model)){
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
  } else {
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

const Main = ({model, dispatch}) => {
  return(
    <div>
      <PageTitle model={model} dispatch={dispatch}/>
      <Subtitle model={model} dispatch={dispatch}/>
      <ResultSummary model={model} dispatch={dispatch}/>
      <Table model={model} dispatch={dispatch}/>
      <InlineArticles model={model} dispatch={dispatch}/>
      <CategoryLinkController model={model} dispatch={dispatch}/>
    </div>
  );
}

export default Template;
