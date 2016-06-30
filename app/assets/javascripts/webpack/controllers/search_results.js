import React from "react";
import {
  searchResults,
  selectedCollectionFilter,
  selectedGeographicFilter,
  selectedSearchResult,
  link,
  recordAnalytics
} from "controller_helpers/search_results";
import {
  selectCollectionFilter,
  selectGeographicFilter,
  closeSearch,
  searchResultSelected
} from "action_creators";
import ReferentStatusIcon from "controllers/referent_status_icon";
import _ from "lodash";
import ExpandingContainer from "component_helpers/expanding_container";
import hiddenFromUsers from "controller_helpers/hidden_from_users";

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
        <div className="livesearch__inner-results-container">
          <Filters model={this.props.model} dispatch={this.props.dispatch}/>
          <SearchResults model={this.props.model} dispatch={this.props.dispatch}/>
        </div>
      </ExpandingContainer>
    );
  }
})

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
  if(searchResults(model).pwPipe(_.some)){
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

const Filters = ({model, dispatch}) => {
  return(
    <div className="livesearch__customize-container">
      <CollectionFilter model={model} dispatch={dispatch}/>
      <GeographicFilter model={model} dispatch={dispatch}/>
    </div>
  );
}

const GeographicFilter = ({model, dispatch}) => {
  if(_.includes(
    ["Physician Resources", "Patient Info"],
    selectedCollectionFilter(model))){

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
      <Result
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
  return !_.isUndefined(model.ui.searchTerm) &&
    model.ui.searchTerm.length > 0;
};

const GroupHeading = ({model, dispatch, label}) => {
  return(
    <li className="group">{ label }</li>
  );
}

const Result = ({model, dispatch, decoratedRecord}) => {
  return(
    <li className={resultClassname(decoratedRecord, model)}
      onMouseEnter={_.partial(searchResultSelected, dispatch, decoratedRecord.index)}
    >
      <InnerResult record={decoratedRecord.raw} model={model}/>
    </li>
  );
}

const resultClassname = (decoratedRecord, model) => {
  let classes = ["search-result"]

  if(decoratedRecord.index === selectedSearchResult(model)){
    classes.push("selected");
  }

  if(hiddenFromUsers(decoratedRecord.raw, model)) {
    classes.push("hidden-from-users");
  }

  return classes.join(" ");
}

const InnerResult = ({record, model}) => {
  if (_.includes(["specialists", "clinics"], record.collectionName)){
    return(
      <a href={link(record)} onClick={_.partial(recordAnalytics, record, model)}>
        <div className="search_name">
          <ReferentStatusIcon record={record} model={model}/>
          <span style={{marginLeft: "5px"}}>{label(record)}</span>
        </div>
        <div className="search_specialties">
          { record.specializationIds.join(", ") }
        </div>
        <div className="search_city">
          { cities(record).map((id) => model.app.cities[id].name).join(", ") }
        </div>
      </a>
    );
  }
  else if (record.collectionName === "procedures"){
    return(
      <a href={link(record)} onClick={_.partial(recordAnalytics, record, model)}>
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
      <a href={link(record)} onClick={_.partial(recordAnalytics, record, model)}>
        <div className="search_name full_width">{label(record)}</div>
      </a>
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

export default SearchResultsDropdown;
