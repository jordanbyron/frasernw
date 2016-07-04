import Template from "controllers/template";
import SearchResults from "controllers/search_results";
import SearchBox from "controllers/search_box";
import Provider from "provider";
import createLogger from "redux-logger";
import nextAction from "middlewares/next_action";
import { createStore, applyMiddleware } from "redux";
import { useQueries } from 'history';
import ReactDOM from "react-dom";
import rootReducer from "reducers/root_reducer";
import React from "react";
import changeTab from "middlewares/change_tab";
import setSearchListeners from "set_search_listeners";
import {
  requestDynamicData,
  parseRenderedData,
  integrateLocalStorageData,
  parseLocation
} from "action_creators";

const bootstrapReact = function() {
  if (!window.pathways.isLoggedIn){
    return false;
  }

  let middlewares = [];

  if(window.pathways.environment !== "production"){
    const logger = createLogger();
    middlewares.push(logger);
  }

  middlewares.push(changeTab);

  middlewares.push(nextAction);

  const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
  const store = createStoreWithMiddleware(rootReducer);

  parseLocation(store.dispatch);

  window.addEventListener("hashchange", () => {
    parseLocation(store.dispatch);
  })

  $(document).ready(function() {
    const renderTemplateTo = document.getElementById("react_root--template");
    if (renderTemplateTo){
      ReactDOM.render(
        <Provider childKlass={Template} store={store}/>,
        renderTemplateTo
      )
    }

    const renderSearchResultsTo = document.getElementById("navbar_search--results");
    ReactDOM.render(
      <Provider childKlass={SearchResults} store={store}/>,
      renderSearchResultsTo
    )

    const renderSearchBoxTo = document.getElementById("react_root--search");
    ReactDOM.render(
      <Provider childKlass={SearchBox} store={store}/>,
      renderSearchBoxTo
    )
    // setSearchListeners(store.dispatch);

    window.pathways.globalDataLoaded.done(function(data) {
      integrateLocalStorageData(store.dispatch, data);
    })

    parseRenderedData(window.pathways.dataForReact, store.dispatch);

    requestDynamicData(store.getState(), store.dispatch);
  })
};

export default bootstrapReact;
