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
import updateUrlHash from "middlewares/update_url_hash";
import SecretEditLinks from "controllers/secret_edit_links";
import { route } from "controller_helpers/routing";
import {
  parseRenderedData,
  integrateLocalStorageData,
  parseUrl
} from "action_creators";
import FeedbackModal from "controllers/feedback_modal";
import ProcedureSpecializableForm from "controllers/procedure_specializable_form";

const bootstrapReact = function() {
  let middlewares = [];

  if(window.pathways.environment !== "production"){
    const logger = createLogger();
    middlewares.push(logger);
  }

  middlewares.push(updateUrlHash);

  middlewares.push(nextAction);

  const createStoreWithMiddleware = applyMiddleware(...middlewares)(createStore);
  const store = createStoreWithMiddleware(rootReducer);
  window.pathways.reactStore = store;

  parseUrl(store.dispatch);

  window.pathways.parseUrlOnHashChange = true;
  window.addEventListener("hashchange", () => {
    if (window.pathways.parseUrlOnHashChange) {
      parseUrl(store.dispatch);
    }
  })

  $(document).ready(function() {
    // hooked up to global state

    const renderTemplateTo = document.getElementById("react_root--template");
    if (renderTemplateTo){
      ReactDOM.render(
        <Provider childKlass={Template} store={store}/>,
        renderTemplateTo
      )
    }

    const renderSearchResultsTo = document.getElementById("navbar_search--results");
    if (renderSearchResultsTo){
      ReactDOM.render(
        <Provider childKlass={SearchResults} store={store}/>,
        renderSearchResultsTo
      )
    }

    const renderSearchBoxTo = document.getElementById("react_root--search");
    if (renderSearchBoxTo) {
      ReactDOM.render(
        <Provider childKlass={SearchBox} store={store}/>,
        renderSearchBoxTo
      )
    }

    const renderFeedbackModalTo = document.getElementById("react_root--feedback");
    ReactDOM.render(
      <Provider childKlass={FeedbackModal} store={store}/>,
      renderFeedbackModalTo
    )

    if(window.pathways.globalDataLoaded){
      window.pathways.globalDataLoaded.done(function(data) {
        integrateLocalStorageData(store.dispatch, data);
      })
    }

    parseRenderedData(window.pathways.dataForReact, store.dispatch);

    // standalone

    const standaloneComponents = {
      SecretEditLinks: SecretEditLinks,
      ProcedureSpecializableForm: ProcedureSpecializableForm
    }

    $(".standalone-react-component").each((index, elem) => {
      const reactElement = React.createElement(
        standaloneComponents[elem.getAttribute("data-react-component")],
        JSON.parse(elem.getAttribute("data-react-props"))
      );
      ReactDOM.render(reactElement, elem);
    })
  })
};

export default bootstrapReact;
