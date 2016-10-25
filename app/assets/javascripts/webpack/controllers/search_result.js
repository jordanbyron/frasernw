import React from "react";
import _ from "lodash";
import {
  selectedSearchResult,
  recordAnalytics,
  highlightSelectedSearchResult,
  entryLabel,
  selectedCollectionFilter,
  adjustedLink
} from "controller_helpers/search_results";
import {
  searchResultSelected,
  hoverLeaveSearchResult,
  closeSearch
} from "action_creators";
import ReferentStatusIcon from "controllers/referent_status_icon";
import hiddenFromUsers from "controller_helpers/hidden_from_users";

const SearchResult = ({model, dispatch, decoratedRecord}) => {
  return(
    <li className={resultClassname(decoratedRecord, model)}>
      <a href={adjustedLink(model, decoratedRecord.raw)}
        onClick={_.partial(onClick, model, dispatch, decoratedRecord.raw)}
        onMouseEnter={_.partial(searchResultSelected, dispatch, decoratedRecord.index)}
        onMouseLeave={_.partial(hoverLeaveSearchResult, dispatch)}
        style={{width: "calc(100% - 20px)"}}
      >
        { InnerResult(decoratedRecord, model) }
      </a>
    </li>
  );
}

const onClick = (model, dispatch, record) => {
  recordAnalytics(record, model)

  closeSearch(dispatch);
}


const resultClassname = (decoratedRecord, model) => {
  let classes = ["search-result"]

  if(decoratedRecord.index === selectedSearchResult(model) &&
    highlightSelectedSearchResult(model)){

    classes.push("selected");
  }

  if(hiddenFromUsers(decoratedRecord.raw, model)) {
    classes.push("hidden-from-users");
  }

  return classes.join(" ");
}

const InnerResult = (decoratedRecord, model) => {
  var record = decoratedRecord.raw;

  if (_.includes(["specialists", "clinics"], record.collectionName)){
    return(
      [
        <div className="search_name" key="name">
          <ReferentStatusIcon record={record} model={model}/>
          <span style={{marginLeft: "5px"}}>
            <HighlightedEntryLabel decoratedRecord={decoratedRecord}/>
          </span>
        </div>,
        <div className="search_specialties" key="specialties">
          {
            record.
              specializationIds.
              map(_.propertyOf(model.app.specializations)).
              map(_.property("name")).
              join(", ")
          }
        </div>,
        <div className="search_city" key="city">
          { cities(record).map((id) => model.app.cities[id].name).join(", ") }
        </div>
      ]
    );
  }
  else if (record.collectionName === "procedures"){
    let returning = []

    returning.push(
      <div className="search_name" key="name">
        <HighlightedEntryLabel decoratedRecord={decoratedRecord}/>
      </div>
    )

    if(!_.includes(["Specialists", "Clinics"], selectedCollectionFilter(model))){
      returning.push(
        <div className="search_specialties no_city" key="specialties">
          {
            record.
              specializationIds.
              map((id) => model.app.specializations[id].name) .
              join(", ")
          }
        </div>
      )
    }

    return returning;
  }
  else {
    return(
      [
        <div className="search_name full_width" key="name">
          <HighlightedEntryLabel decoratedRecord={decoratedRecord}/>
        </div>
      ]
    );
  }
}

const HighlightedEntryLabel = ({decoratedRecord}) => {
  const _highlightedTokens = decoratedRecord.
    queriedTokensWithMatchIndices.
    reduce((accumulatingTokens, queriedTokenWithMatchIndices, tokenIndex, iteratingOver) => {

    const _matchIndices = queriedTokenWithMatchIndices[1];

    let _currentFragment = [];
    const _queriedTokenFragments = queriedTokenWithMatchIndices[0].
      split("").
      reduce((accumulatingFragments, char, indexWithinToken, iteratingOver) => {

      _currentFragment.push(char);

      const _highlightingThisChar = _.includes(
        _matchIndices,
        indexWithinToken
      )
      const _highlightingNextChar = _.includes(
        _matchIndices,
        (indexWithinToken + 1)
      )

      if (_highlightingThisChar !== _highlightingNextChar ||
          (indexWithinToken + 1 === iteratingOver.length)){

        accumulatingFragments.push(
          <span key={indexWithinToken} className={(_highlightingThisChar ? "highlight" : "")}>
            { _currentFragment.join("") }
          </span>
        );

        _currentFragment = [];
      }

      return accumulatingFragments;
    }, [])

    accumulatingTokens.push(<span key={tokenIndex}>{ _queriedTokenFragments }</span>);
    accumulatingTokens.push(<span key={`space${tokenIndex}`}>{" "}</span>);

    return accumulatingTokens;
  }, [])

  return(
    <span>{ _highlightedTokens }</span>
  )
}

const cities = (record) => {
  if (record.collectionName === "clinics" ||
    (record.isOpen)){

    return record.cityIds;
  }
  else {
    return [];
  }
}

export default SearchResult;
