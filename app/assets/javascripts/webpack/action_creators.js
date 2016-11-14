import * as FilterValues from "controller_helpers/filter_values";
import { route } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { cities as cityFilterSubkeys } from "controller_helpers/filter_subkeys";
import _ from "lodash";

export function requestDynamicData(model, dispatch){
  if(route === "/reports/page_views_by_user"){
    requestingData(dispatch)

    const requestParams = {
      divisionId: FilterValues.divisionScope(model),
      startMonth: FilterValues.startMonth(model),
      endMonth: FilterValues.endMonth(model)
    }

    $.get(
      "/api/v1/reports/page_views_by_user",
      { data: requestParams }
    ).done(function(data) {
      dispatch({
        type: "DATA_RECEIVED",
        recordsToDisplay: data.recordsToDisplay
      })
    })
  }
  else if (route === "/reports/entity_page_views") {
    requestingData(dispatch)

    const requestParams = {
      start_month_key: FilterValues.startMonth(model),
      end_month_key: FilterValues.endMonth(model),
      division_id: FilterValues.divisionScope(model),
      record_type: FilterValues.entityType(model)
    }

    $.get(
      "/api/v1/reports/entity_page_views",
      requestParams
    ).done(function(data) {
      dispatch({
        type: "DATA_RECEIVED",
        recordsToDisplay: data.recordsToDisplay
      })
    });
  }
}

export function requestingData(dispatch) {
  dispatch({
    type: "REQUESTING_DATA"
  })
}

export function parseRenderedData(data, dispatch) {
  dispatch({
    type: "PARSE_RENDERED_DATA",
    data: data
  });
};

export function sortByHeading(dispatch, key, currentKey, model) {
  dispatch({
    type: "SORT_BY_HEADING",
    tabKey: selectedTabKey(model),
    currentKey: currentKey,
    key: key
  })
}

export function locationChanged(dispatch, newLocation) {
  dispatch({
    type: "LOCATION_CHANGED",
    location: newLocation
  });
}

export function integrateLocalStorageData(dispatch, data) {
  dispatch({
    type: "INTEGRATE_LOCALSTORAGE_DATA",
    data: data
  });
}

export function tabClicked(dispatch, model, tabKey) {
  dispatch({
    type: "TAB_CLICKED",
    proposed: tabKey
  })
}

export function selectReducedView(dispatch, newView) {
  dispatch({
    type: "SELECT_REDUCED_VIEW",
    newView: newView
  })
}

export function toggleFilterGroupExpansion(dispatch, tabKey, filterGroupKey, proposed){
  dispatch({
    type: "TOGGLE_FILTER_GROUP_EXPANSION",
    tabKey: tabKey,
    filterGroupKey: filterGroupKey,
    proposed: proposed
  })
}


export function changeFilter(dispatch, tabKey, filterKey, filterSubKey, event) {
  if(event.target.type !== "radio" || event.target.checked) {
    if (event.target.type === "checkbox"){
      var proposedValue = event.target.checked;
    }
    else {
      var proposedValue = event.target.value;
    }

    changeFilterToValue(
      dispatch,
      tabKey,
      filterKey,
      filterSubKey,
      proposedValue
    )
  }
}

export function changeFilterToValue(dispatch, tabKey, filterKey, filterSubKey, proposed) {
  dispatch({
    type: "CHANGE_FILTER_VALUE",
    tabKey: tabKey,
    filterKey: filterKey,
    filterSubKey: filterSubKey,
    proposed: proposed
  })
};

export function toggleUnfocusedProcedureVisibility(dispatch, proposed, tabKey) {
  dispatch({
    type: "TOGGLE_UNFOCUSED_PROCEDURE_VISIBILITY",
    tabKey: tabKey,
    proposed: proposed
  })
}

const proposedCityFilterValues = (activatedIds, model) => {
  return cityFilterSubkeys(model).map((id) => {
    return [ id, _.includes(activatedIds, id) ];
  }).pwPipe(_.zipObject)
};

export function updateCityFilters(dispatch, model, activatedIds) {
  dispatch({
    type: "UPDATE_CITY_FILTERS",
    tabKey: selectedTabKey(model),
    proposed: proposedCityFilterValues(activatedIds, model)
  });
}

export function parseUrl(dispatch){
  dispatch({
    type: "PARSE_URL_HASH"
  })
}

export const openFeedbackModal = (dispatch, target) => {
  dispatch({
    type: "OPEN_FEEDBACK_MODAL",
    target: target
  });
};

export function clearFilters(dispatch, model) {
  dispatch({
    type: "CLEAR_FILTERS",
    tabKey: selectedTabKey(model)
  });
}

export function toggleSpecializationFilter(dispatch, model, proposed) {
  dispatch({
    type: "TOGGLE_SPECIALIZATION_FILTER",
    tabKey: selectedTabKey(model),
    proposed: proposed
  });
}

export const toggleUpdateVisibility = (dispatch, update) => {
  const updateIdentifiers = _.omit(update, "markup", "hidden", "manual");
  const params = _.assign(
    {},
    updateIdentifiers,
    { hide: !update.hidden }
  );

  dispatch({
    type: "TOGGLE_UPDATE_VISIBILITY",
    update: updateIdentifiers,
    hide: !update.hidden
  });

  $.ajax({
    url: `/latest_updates/toggle_visibility`,
    type: "PATCH",
    data: {update: params }
  })
};

export const setPage = (dispatch, proposed, model) => {
  dispatch({
    type: "SET_PAGE",
    proposed: proposed,
    tabKey: selectedTabKey(model)
  })
}

const submittingFeedback = (dispatch) => {
  dispatch({
    type: "SET_FEEDBACK_MODAL_STATE",
    proposed: "SUBMITTING"
  })
}

const doneSubmittingFeedback = (dispatch) => {
  dispatch({
    type: "SET_FEEDBACK_MODAL_STATE",
    proposed: "POST_SUBMIT"
  })
}

export const submitFeedback = (dispatch, model, name, email, comment) => {
  if (!comment){

    return;
  }
  else if (model.app.currentUser.role === "unauthenticated" &&
    (!name || !email)){

    return;
  }
  else {
    $.post("/feedback_items", {
      feedback_item: {
        target_id: model.ui.feedbackModal.target.id,
        target_type: model.ui.feedbackModal.target.klass,
        freeform_name: name,
        freeform_email: email,
        feedback: comment
      }
    }).success(() => {
      doneSubmittingFeedback(dispatch);
    })

    submittingFeedback(dispatch);
  }
}

export const closeFeedbackModal = (dispatch) => {
  dispatch({
    type: "SET_FEEDBACK_MODAL_STATE",
    proposed: "CLOSED"
  })
}

export const toggleRowExpansion = (model, dispatch, proposed, e) => {
  dispatch({
    type: "TOGGLE_ROW_EXPANSIONS",
    tabKey: selectedTabKey(model),
    proposed: proposed
  });

  e.stopPropagation();
};
export const searchFocused = (dispatch, isFocused) => {
  dispatch({
    type: "SEARCH_FOCUS_CHANGED",
    proposed: isFocused
  });
}

export const termSearched = (model, dispatch, term) => {
  if (model.ui.searchTimerId){
    clearTimeout(model.ui.searchTimerId);
  }

  const timerId = setTimeout(function() {
    dispatch({
      type: "SEARCH_TIMEOUT_ENDED"
    })
  }, 150)

  dispatch({
    type: "TERM_SEARCHED",
    proposedTerm: term,
    timerId: timerId
  });

}

export const selectCollectionFilter = (dispatch, label, event) => {
  event.preventDefault();

  dispatch({
    type: "SEARCH_COLLECTION_FILTER",
    proposed: label
  });
}

export const selectGeographicFilter = (dispatch, label, event) => {
  event.preventDefault();

  dispatch({
    type: "SEARCH_GEOGRAPHIC_FILTER",
    proposed: label
  });
}

export const closeSearch = (dispatch) => {
  dispatch({
    type: "CLOSE_SEARCH"
  });
}

export const searchResultSelected = (dispatch, proposed) => {
  dispatch({
    type: "SEARCH_RESULT_SELECTED",
    proposed: proposed
  });
}

export const hoverLeaveSearchResult = (dispatch) => {
  dispatch({
    type: "HOVER_LEAVE_SEARCH_RESULT"
  });
}

export const toggleBreadcrumbDropdown = (dispatch, proposed) => {
  dispatch({
    type: "TOGGLE_BREADCRUMB_DROPDOWN",
    proposed: proposed
  })
}
