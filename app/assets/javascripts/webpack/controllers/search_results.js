import React from "react";
import {
  searchResults,
  selectedCollectionFilter,
  selectedGeographicFilter
} from "controller_helpers/search_results";
import {
  selectCollectionFilter,
  selectGeographicFilter,
  closeSearch
} from "action_creators";
import ReferentStatusIcon from "controllers/referent_status_icon";
import _ from "lodash";

const SearchResults = ({model, dispatch}) => {
  if(shouldDisplay(model)){
    return(
      <div id="search_results">
        <div className="livesearch__inner-results-container">
          <Filters model={model} dispatch={dispatch}/>
          <ul className="search_results">
            {
              searchResults(model).
                map((group) => resultGroup(model, group)).
                pwPipe(_.flatten)
            }
          </ul>
        </div>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const Filters = ({model, dispatch}) => {
  return(
    <div className="livesearch__customize-container">
      <CollectionFilter model={model} dispatch={dispatch}/>
      <GeographicFilter model={model} dispatch={dispatch}/>
    </div>
  );
}

const GeographicFilter = ({model, dispatch}) => {
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
      onClick={_.partial(selectGeographicFilter, dispatch, label)}
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
            "Patient Info"
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
      onClick={_.partial(selectCollectionFilter, dispatch, label)}
    >
      <a>{ label }</a>
    </li>
  );
};

const resultGroup = (model, group) => {
  return [
    <GroupHeading
      model={model}
      label={group.label}
      key={group.label}
    />,
    resultGroupEntries(model, group.records)
  ].pwPipe(_.flatten)
};

const resultGroupEntries = (model, records) => {
  return records.map((record) => {
    return <Result model={model} record={record} key={key(record)}/>
  })
}

const key = (record) => {
  return `${record.collectionName}${record.id}`;
};

const shouldDisplay = (model) => {
  return true &&
    model.ui.searchTerm &&
    model.ui.searchTerm.length > 0;
};

const GroupHeading = ({model, dispatch, label}) => {
  return(
    <li className="group">{ label }</li>
  );
}

const Result = ({model, dispatch, record}) => {
  return(
    <li className="search-result">
      <InnerResult record={record} model={model}/>
    </li>
  );
}

const InnerResult = ({record, model}) => {
  if (_.includes(["specialists", "clinics"], record.collectionName)){
    return(
      <a href={link(record)}>
        <div className="search_name">
          <ReferentStatusIcon record={record} model={model}/>
          <span style={{marginLeft: "5px"}}>{label(record)}</span>
        </div>
        <div className="search_specialties">
          {
            record.
              specializationIds.
              map((id) => model.app.specializations[id].name).
              join(", ")
          }
        </div>
        <div className="search_city">
          { record.cityIds.map((id) => model.app.cities[id].name).join(", ") }
        </div>
      </a>
    );
  }
  else if (record.collectionName === "procedures"){
    return(
      <a href={link(record)}>
        <div className="search_name">{label(record)}</div>
        <div className="search_specialties no_city">
          {
            record.
              specializationIds.
              map((id) => model.app.specializations[id].name) .
              join(", ")
          }
        </div>
      </a>
    );
  }
  else {
    return(
      <a href={link(record)}>
        <div className="search_name full_width">{label(record)}</div>
      </a>
    );
  }
}

const link = (record) => {
  return `/${record.collectionName}/${record.id}`;
}

const label = (record) => {
  if (record.collectionName === "specialists" && record.billingNumber){
    return `${record.name} - MSP #${record.billingNumber}`;
  }
  else if (_.includes(["procedures", "contentCategories"], record.collectionName)){
    return record.fullName;
  }
  else if (record.collectionName === "contentItems"){
    return record.title;
  }
  else {
    return record.name;
  }
}

export default SearchResults;
