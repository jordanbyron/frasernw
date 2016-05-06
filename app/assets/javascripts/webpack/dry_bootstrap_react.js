import TemplateController from "controllers/template";
import Provider from "provider";
import createLogger from "redux-logger";
import nextAction from "middlewares/next_action";
import { createStore, applyMiddleware } from "redux";
import createBrowserHistory from 'history/lib/createBrowserHistory'
import { useQueries } from 'history';
import ReactDOM from "react-dom";
import rootReducer from "dry_reducers/root_reducer";
import React from "react";
import { requestDynamicData, parseRenderedData, locationChanged, integrateLocalStorageData } from "action_creators";

let middlewares = [];
const logger = createLogger();
middlewares.push(logger);
middlewares.push(nextAction);

const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
const store = createStoreWithMiddleware(rootReducer);

const browserHistory = useQueries(createBrowserHistory)();
browserHistory.listen((location) => {
  locationChanged(store.dispatch, location);
});

const dryBootstrapReact = function() {
  $(document).ready(function() {
    const renderTo = document.getElementById("react_root--template");

    if (renderTo){
      ReactDOM.render(
        <Provider childKlass={TemplateController} store={store}/>,
        renderTo
      )
    }

    window.pathways.globalDataLoaded.done(function(data) {
      integrateLocalStorageData(store.dispatch, data);
    })

    requestDynamicData(store.getState(), store.dispatch);
    parseRenderedData(store.dispatch);
  })
}

export default dryBootstrapReact;
