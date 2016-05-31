import React from "react";
import { selectedTableHeadingKey, headingArrowDirection }
  from "controller_helpers/table_headings";
import { sortByHeading } from "action_creators";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName, collectionShownPluralLabel }
  from "controller_helpers/collection_shown";
import { entityType } from "controller_helpers/filter_values";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import _ from "lodash";

const TableHeading = ({model, dispatch}) => {
  if(_.includes(["/reports/entity_page_views", "/latest_updates"], matchedRoute(model))){
    return <thead></thead>
  }
  else {
    return(
      <thead>
        <tr>
          { cells(model, dispatch) }
        </tr>
      </thead>
    );
  }
};

const cells = (model, dispatch) => {
  let _classnamePrefix = classnamePrefix(model);

  return cellConfigs(model).map((config) => {
    return(
      <TableHeadingCell
        model={model}
        dispatch={dispatch}
        label={config.label}
        key={config.key}
        headingKey={config.key}
        classnamePrefix={_classnamePrefix}
      />
    );
  })
}

const classnamePrefix = (model) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    return "referents";
  }
  else if (collectionShownName(model) === "contentItem") {
    return "content-items";
  }
  else {
    return "";
  }
}

const cellConfigs = (model) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    if (showingMultipleSpecializations(model)){
      return [
        { label: collectionShownPluralLabel(model), key: "NAME" },
        { label: "Specialties", key: "SPECIALTIES" },
        { label: "Accepting New Referrals?", key: "REFERRALS" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME"},
        { label: "City", key: "CITY" }
      ];
    }
    else {
      return [
        { label: collectionShownPluralLabel(model), key: "NAME" },
        { label: "Accepting New Referrals?", key: "REFERRALS" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME"},
        { label: "City", key: "CITY" }
      ];
    }
  }
  else if (collectionShownName(model) === "contentItems") {
    return [
      { label: "Title", key: "TITLE" },
      { label: "Category", key: "SUBCATEGORY" },
      { label: "", key: "FAVOURITE" },
      { label: "", key: "EMAIL" },
      { label: "", key: "FEEDBACK" }
    ];
  }
  else if (matchedRoute(model) === "/reports/pageviews_by_user"){
    return [
      { label: "User", key: "USERS" },
      { label: "Page Views", key: "PAGE_VIEWS" }
    ];
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty"){
    return [
      { label: "Specialty", key: "SPECIALTY" },
      { label: _.capitalize(entityType(model)), key: "ENTITY_TYPE" }
    ];
  }
};

const TableHeadingCell = ({model, dispatch, label, headingKey, classnamePrefix}) => {
  const onClick = _.partial(
    sortByHeading,
    dispatch,
    headingKey,
    selectedTableHeadingKey(model)
  );

  return(
    <th onClick={onClick}
      className={[
        "datatable__th",
        classnamePrefix,
        headingKey.toLowerCase()
      ].filter((elem) => elem !== "").join("--")}
    >
      <span>{ label }</span>
      <TableHeadingArrow
        model={model}
        headingKey={headingKey}
      />
    </th>
  );
}

const TableHeadingArrow = ({model, headingKey}) => {
  if (selectedTableHeadingKey(model) === headingKey) {
    return(
      <i className={`icon-arrow-${headingArrowDirection(model).toLowerCase()}`}
        style={{color: "#08c", marginLeft: "5px"}}
      />
    );
  }
  else {
    return(<span></span>)
  }
}

export default TableHeading;
