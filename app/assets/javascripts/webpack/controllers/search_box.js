import React from "react";
import {
  searchFocused,
  selectCollectionFilter,
  termSearched,
  searchResultSelected,
  closeSearch,
} from "action_creators";
import {
  selectedSearchResult,
  searchResults,
  recordAnalytics,
  adjustedLink,
  groupedSearchResults
} from "controller_helpers/search_results"
import { link } from "controller_helpers/links";
import { selectedCollectionFilter } from "controller_helpers/search_results";
import { CollectionFilterValues } from "controller_helpers/search_filter_values";

const SearchBox = React.createClass({
  componentDidMount: function() {
    this.refs.query.focus();
  },
  render: function(){
    var model, dispatch;
    ({ model, dispatch } = this.props);

    return(
      <input className="span3 search-query icon" id="search" ref="query"
        onFocus={_.partial(searchFocused, dispatch, true)}
        onBlur={_.partial(searchFocused, dispatch, false)}
        onChange={(e) => termSearched(model, dispatch, e.target.value)}
        onKeyDown={_.partial(handleKeyDown, model, dispatch)}
        value={model.ui.searchTerm}
        autoComplete="off"
        placeholder="&#xf002; Search"
      />
    );
  }
});

const UP_KEY_CODE = 38;
const DOWN_KEY_CODE = 40;
const ENTER_KEY_CODE = 13;
const ESCAPE_KEY_CODE = 27;
const TAB_KEY_CODE = 9;

const handleKeyDown = (model, dispatch, event) => {
  if(event.keyCode === UP_KEY_CODE && selectedSearchResult(model) > 0){
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) - 1)
    )
  }
  else if (event.keyCode === DOWN_KEY_CODE &&
    ((selectedSearchResult(model) + 1) < searchResults(model).length)) {
    searchResultSelected(
      dispatch,
      (selectedSearchResult(model) + 1)
    )
  }
  else if (event.keyCode === ENTER_KEY_CODE){
    recordAnalytics(selectedSearchResultRecord(model), model);
    window.location = adjustedLink(model, selectedSearchResultRecord(model));
    closeSearch(dispatch);
  }
  else if (event.keyCode === ESCAPE_KEY_CODE){
    closeSearch(dispatch);
  }
  else if (event.keyCode === TAB_KEY_CODE){
    var currentIndex = _.findIndex(
      CollectionFilterValues,
      (label) => selectedCollectionFilter(model) === label
    );
    if (currentIndex + 1 === CollectionFilterValues.length){
      var nextIndex = 0;
    }
    else{
      var nextIndex = currentIndex + 1;
    }

    selectCollectionFilter(
      dispatch,
      CollectionFilterValues[nextIndex],
      event
    )
  }
}

const selectedSearchResultRecord = (model) => {
  return groupedSearchResults(model).
    map(_.property("decoratedRecords")).
    pwPipe(_.flatten).
    find((decoratedRecord) => decoratedRecord.index === selectedSearchResult(model)).
    raw;
}

export default SearchBox;
