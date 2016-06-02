import React from "react";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import TableRows from "controllers/table_rows";
import TableHeading from "controllers/table_heading";
import { reportStyle } from "controller_helpers/filter_values";
import { recordShownByTab, isTabbedPage } from "controller_helpers/tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";
import isDataDubious from "controller_helpers/dubious_data";

const Table = ({model, dispatch}) => {
  if (shouldShow(model)){
    return (
      <table className="table">
        <TableHeading model={model} dispatch={dispatch}/>
        <tbody>
          { TableRows(model, dispatch) }
        </tbody>
      </table>
    );
  }
  else {
    return(<span></span>);
  }
}

const shouldShow = (model) => {
  if (!_.includes(ROUTES_IMPLEMENTING, matchedRoute(model))){
    return false;
  }

  if (isTabbedPage(model) &&
    collectionShownName(model) === "contentItems" &&
    !(recordShownByTab(model).componentType === "FilterTable")) {

    return false;
  }

  if (matchedRoute(model) === "/content_categories/:id" &&
    !(recordShownByPage(model).componentType === "FilterTable")) {

    return false;
  }

  if (matchedRoute(model) === "/reports/referents_by_specialty" &&
    (reportStyle(model) === "expanded")) {

    return false;
  }

  if (matchedRoute(model) === "/reports/entity_page_views" &&
    (!model.ui.recordsToDisplay ||
      (isDataDubious(model) && model.app.currentUser.role !== "super"))) {

    return false;
  }

  if (!isTableLoaded(model)) {
    return false
  }

  return true;
}

const isTableLoaded = (model) => {
  if(matchedRoute(model) === "/reports/pageviews_by_user"){
    return model.ui.recordsToDisplay;
  }
  else {
    return true
  }
}

const ROUTES_IMPLEMENTING = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/pageviews_by_user",
  "/reports/entity_page_views",
  "/reports/referents_by_specialty",
  "/latest_updates",
  "/hospitals/:id",
  "/languages/:id",
  "/news_items"
];

export default Table;
