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

const SearchResult = ({model, dispatch, decoratedRecord}) => {
  return(
    <li className={resultClassname(decoratedRecord, model)}>
      <a href={link(decoratedRecord.raw)}
        onClick={_.partial(onClick, model, dispatch, decoratedRecord.raw)}
        onMouseEnter={_.partial(searchResultSelected, dispatch, decoratedRecord.index)}
        onMouseLeave={_.partial(hoverLeaveSearchResult, dispatch)}
        style={{width: "calc(100% - 20px)"}}
      >
        { InnerResult(decoratedRecord.raw, model) }
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

const InnerResult = (record, model) => {
  if (_.includes(["specialists", "clinics"], record.collectionName)){
    return(
      [
        <div className="search_name" key="name">
          <ReferentStatusIcon record={record} model={model}/>
          <span style={{marginLeft: "5px"}}>{entryLabel(record)}</span>
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
        <div className="search_name" key="name">{entryLabel(record)}</div>,
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
        <div className="search_name full_width" key="name">{entryLabel(record)}</div>
      ]
    );
  }
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
