import React from "react";
import _ from "lodash";
import {
  selectedSearchResult,
  recordAnalytics,
  highlightSelectedSearchResult,
  entryLabel
} from "controller_helpers/search_results";
import { link } from "controller_helpers/links";
import {
  searchResultSelected,
  hoverLeaveSearchResult,
  closeSearch
} from "action_creators";
import ReferentStatusIcon from "controllers/referent_status_icon";
import hiddenFromUsers from "controller_helpers/hidden_from_users";
import { match } from "fuzzaldrin";

const SearchResult = ({model, dispatch, decoratedRecord}) => {
  return(
    <li className={resultClassname(decoratedRecord, model)}>
      <a href={link(decoratedRecord.item)}
        onClick={_.partial(onClick, model, dispatch, decoratedRecord.item)}
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

  if(hiddenFromUsers(decoratedRecord.item, model)) {
    classes.push("hidden-from-users");
  }

  return classes.join(" ");
}

const InnerResult = (decoratedRecord, model) => {
  var record = decoratedRecord.item;

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
    return(
      [
        <div className="search_name" key="name">
          <HighlightedEntryLabel decoratedRecord={decoratedRecord}/>
        </div>,
        <div className="search_specialties no_city" key="specialties">
          {
            record.
              specializationIds.
              map((id) => model.app.specializations[id].name) .
              join(", ")
          }
        </div>
      ]
    );
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
  var highlightedTokens = decoratedRecord.
    tokensWithMatchedQueries.
    map((tokenWithQuery, index) => {

    var _matches = tokenWithQuery[1].map((queryToken) => {
      return match(tokenWithQuery[0], queryToken);
    }).pwPipe(_.flatten).pwPipe(_.uniq).sort();

    var _fragments = [];
    var _currentFragment = [];

    tokenWithQuery[0].split("").forEach((char, index, array) => {
      _currentFragment.push(char);

      var _highlightingThisChar = _.includes(
        _matches,
        index
      )
      var _highlightingNextChar = _.includes(
        _matches,
        (index + 1)
      )

      if (_highlightingThisChar !== _highlightingNextChar || (index + 1 === array.length)){
        _fragments.push(
          <span key={index} className={(_highlightingThisChar ? "highlight" : "")}>
            { _currentFragment.join("") }
          </span>
        )

        _currentFragment = [];
      }
    })

    return(
      <span key={index}>{ _fragments }</span>
    )
  })

  return(
    <span>
      {
        highlightedTokens.map((token, index) => {
          return [token, <span key={`space${index}`}>{" "}</span>]
        }).pwPipe(_.flatten)
      }
    </span>
  )
}

const cities = (record) => {
  if (record.collectionName === "clinics" ||
    (record.respondedToSurvey && record.isAvailable)){

    return record.cityIds;
  }
  else {
    return [];
  }
}

export default SearchResult;
