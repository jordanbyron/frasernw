import React from "react";
import {
  searchFocused,
  termSearched,
  searchResultSelected,
  closeSearch
} from "action_creators";
import { selectedSearchResult, searchResults, link } from "controller_helpers/search_results"

const SearchBox = ({model, dispatch}) => {
  return(
    <input className="span3 search-query icon" id="search navbar_search--query"
      onFocus={_.partial(searchFocused, dispatch, true)}
      onBlur={_.partial(searchFocused, dispatch, false)}
      onChange={(e) => termSearched(dispatch, e.target.value)}
      onKeyDown={_.partial(handleKeyDown, model, dispatch)}
      value={model.ui.searchTerm}
      autoComplete="off"
      placeholder="&#xf002; Search"
    />
  );
};

const UP_KEY_CODE = 38;
const DOWN_KEY_CODE = 40;
const ENTER_KEY_CODE = 13;
const ESCAPE_KEY_CODE = 27;

const handleKeyDown = (model, dispatch, event) => {
  if(event.keyCode === UP_KEY_CODE && selectedSearchResult(model) > 0){
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) - 1)
    )
  }
  else if (event.keyCode === DOWN_KEY_CODE && selectedSearchResult(model) < 10) {
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) + 1)
    )
  }
  else if (event.keyCode === ENTER_KEY_CODE){
    window.location = link(selectedSearchResultRecord(model));
  }
  else if (event.keyCode === ESCAPE_KEY_CODE){
    closeSearch(dispatch);
  }
}

const selectedSearchResultRecord = (model) => {
  return searchResults(model).
    map(_.property("decoratedRecords")).
    pwPipe(_.flatten).
    find((decoratedRecord) => decoratedRecord.index === selectedSearchResult(model)).
    raw;
}

export default SearchBox;
