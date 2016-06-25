import React from "react";
import searchResults from "controller_helpers/search_results";
import _ from "lodash";

const SearchResults = ({model, dispatch}) => {
  if(shouldDisplay(model)){
    return(
      <div id="search_results">
        <ul className="search_results">
          {
            searchResults(model).
              map((group) => resultGroup(model, group)).
              pwPipe(_.flatten)
          }
        </ul>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const resultGroup = (model, group) => {
  return [
    <GroupHeading
      model={model}
      collectionName={group.collectionName}
      key={group.collectionName}
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

const GroupHeading = ({model, dispatch, collectionName}) => {
  return(
    <li className="group">{ _.capitalize(collectionName) }</li>
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
        <div className="search_name">{label(record)}</div>
        <div className="search_specialties">
          {
            record.
              specializationIds.
              map((id) => model.app.specializations[id].name).
              join(", ")
          }
        </div>
        <div className="search_cities">
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
