import Template from "controllers/template";
import Provider from "provider";
import createLogger from "redux-logger";
import nextAction from "middlewares/next_action";
import { createStore, applyMiddleware } from "redux";
import { useQueries } from 'history';
import ReactDOM from "react-dom";
import rootReducer from "dry_reducers/root_reducer";
import React from "react";
import changeTab from "middlewares/change_tab";
import {
  requestDynamicData,
  parseRenderedData,
  integrateLocalStorageData,
  parseLocation
} from "action_creators";

const bootstrapReact = function() {
  let middlewares = [];

  const logger = createLogger();
  middlewares.push(logger);

  middlewares.push(changeTab);

  middlewares.push(nextAction);

  const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
  const store = createStoreWithMiddleware(rootReducer);

  parseLocation(store.dispatch);

  window.addEventListener("hashchange", () => {
    parseLocation(store.dispatch);
  })

  $(document).ready(function() {
    const renderTo = document.getElementById("react_root--template");

    if (renderTo){
      ReactDOM.render(
        <Provider childKlass={Template} store={store}/>,
        renderTo
      )
    }

    window.pathways.globalDataLoaded.done(function(data) {
      integrateLocalStorageData(store.dispatch, data);
    })

    if (window.pathways.dataForReact){
      parseRenderedData(store.dispatch);
    }

    requestDynamicData(store.getState(), store.dispatch);
  })
};

export default bootstrapReact;
