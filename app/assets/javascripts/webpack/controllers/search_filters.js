import React from "react";
import {
  selectedCollectionFilter,
  selectedGeographicFilter
} from "controller_helpers/search_results";
import {
  selectCollectionFilter,
  selectGeographicFilter,
  closeSearch
} from "action_creators";

const SearchFilters = ({model, dispatch}) => {
  return(
    <div className="livesearch__customize-container">
      <CollectionFilter model={model} dispatch={dispatch}/>
      <GeographicFilter model={model} dispatch={dispatch}/>
    </div>
  );
}

const GeographicFilter = ({model, dispatch}) => {
  if((_.includes(
    ["Physician Resources", "Patient Info"],
    selectedCollectionFilter(model)) && model.app.currentUser.role === "user") ||
    selectedCollectionFilter(model) === "Areas of Practice"
  ){

    return <noscript/>;
  }
  else {
    return(
      <div className="livesearch__filter-group livesearch__filter-group--scopes">
        <span className="livesearch__prefix">
          { "In: "}
        </span>
        <ul className="nav nav-pills" id="livesearch__search-categories">
          {
            [
              "My Regional Divisions",
              "All Divisions"
            ].map((label) => {
              return(
                <GeographicFilterTab
                  model={model}
                  dispatch={dispatch}
                  key={label}
                  label={label}
                />
              );
            })
          }
        </ul>
      </div>
    );
  }
};

const GeographicFilterTab = ({model, dispatch, label}) => {
  if (selectedGeographicFilter(model) === label){
    var selectedClassName = " livesearch__search-scope--selected"
  }
  else {
    var selectedClassName = "";
  }

  return(
    <li className={`livesearch__search-scope ${selectedClassName}`}
      onMouseDown={_.partial(selectGeographicFilter, dispatch, label)}
    >
      <a>{ label }</a>
    </li>
  );
};

const CollectionFilter = ({model, dispatch}) => {
  return(
    <div className="livesearch__filter-group">
      <span className="livesearch__prefix">
        { "Show Me: "}
      </span>
      <ul className="nav nav-pills" id="livesearch__search-categories">
        {
          [
            "Everything",
            "Specialists",
            "Clinics",
            "Physician Resources",
            "Patient Info",
            "Areas of Practice"
          ].map((label) => {
            return(
              <CollectionFilterTab
                model={model}
                dispatch={dispatch}
                key={label}
                label={label}
              />
            );
          })
        }
      </ul>
      <i className="icon-remove pull-right livesearch__close-button"
        onClick={_.partial(closeSearch, dispatch)}
      />
    </div>
  );
}

const CollectionFilterTab = ({model, dispatch, label}) => {
  if (selectedCollectionFilter(model) === label){
    var selectedClassName = " livesearch__search-category--selected"
  }
  else {
    var selectedClassName = "";
  }

  return(
    <li className={`livesearch__search-category ${selectedClassName}`}
      onMouseDown={_.partial(selectCollectionFilter, dispatch, label)}
    >
      <a>{ label }</a>
    </li>
  );
};

export default SearchFilters;
