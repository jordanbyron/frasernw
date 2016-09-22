import React from "react";
import { searchResults } from "controller_helpers/search_results";
import _ from "lodash";
import ExpandingContainer from "component_helpers/expanding_container";
import SearchResult from "controllers/search_result";
import SearchFilters from "controllers/search_filters";

const SearchResultsDropdown = React.createClass({
  componentDidUpdate: function() {
    if(shouldDisplay(this.props.model)){
      disablePageScroll()
    }
    else {
      enablePageScroll()
    }
  },
  render: function() {
    return(
      <ExpandingContainer expanded={shouldDisplay(this.props.model)}
        containerId="search_results"
        style={{maxHeight: maxHeight()}}
      >
        <DropdownContents model={this.props.model} dispatch={this.props.dispatch}/>
      </ExpandingContainer>
    );
  }
})

const DropdownContents = ({model, dispatch}) => {
  if(shouldDisplay(model)){
    return(
      <div className="livesearch__inner-results-container"
        onMouseDown={(e) => e.preventDefault()}>
        <SearchFilters model={model} dispatch={dispatch}/>
        <SearchResults model={model} dispatch={dispatch}/>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const maxHeight = () => {
  return $(window).height() -
    $("#main-nav").offset().top -
    $("#main-nav").height();
}

const disablePageScroll = () => {
  $("html").css("height", "100%");
  $("body").css("height", "100%");
  $("body").css("padding-bottom", "0px");
  $("body").css("overflow", "hidden");
}
const enablePageScroll = () => {
  $("html").css("height", "");
  $("body").css("height", "");
  $("body").css("padding-bottom", "");
  $("body").css("overflow", "");
}

const SearchResults = ({model, dispatch}) => {
  if (_.isNumber(model.ui.searchTimerId)){
    return(
      <ul className="search_results">
        <li className="empty">Searching...</li>
      </ul>
    );
  }
  else if(searchResults(model).pwPipe(_.some)){
    return(
      <ul className="search_results">
        {
          searchResults(model).
            map((group) => resultGroup(model, group, dispatch)).
            pwPipe(_.flatten)
        }
      </ul>
    )
  }
  else {
    return(
      <ul className="search_results">
        <li className="empty">No Results</li>
      </ul>
    );
  }
}


const resultGroup = (model, group, dispatch) => {
  return [
    <GroupHeading
      model={model}
      label={group.label}
      key={group.label}
    />,
    resultGroupEntries(model, group.decoratedRecords, dispatch)
  ].pwPipe(_.flatten)
};

const resultGroupEntries = (model, decoratedRecords, dispatch) => {
  return decoratedRecords.map((decoratedRecord) => {
    return(
      <SearchResult
        model={model}
        dispatch={dispatch}
        decoratedRecord={decoratedRecord}
        key={key(decoratedRecord.raw)}
      />
    );
  })
}

const key = (record) => {
  return `${record.collectionName}${record.id}`;
};

const shouldDisplay = (model) => {
  return (model.ui.searchIsFocused || false) &&
    !_.isUndefined(model.ui.searchTerm) &&
    model.ui.searchTerm.length > 0;
};

const GroupHeading = ({model, dispatch, label}) => {
  return(
    <li className="group">{ label }</li>
  );
}
export default SearchResultsDropdown;
