import React from "react";
import { selectedTableHeadingKey, headingArrowDirection, canSelectSort }
  from "controller_helpers/table_headings";
import { sortByHeading } from "action_creators";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName, collectionShownPluralLabel }
  from "controller_helpers/collection_shown";
import { entityType } from "controller_helpers/filter_values";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import { buttonIsh } from "stylesets";
import _ from "lodash";
import { memoizePerRender } from "utils";

const TableHeading = ({model, dispatch}) => {
  if(_.includes(["/reports/entity_page_views", "/latest_updates"], matchedRoute(model))){
    return <thead></thead>
  }
  else {
    return(
      <thead>
        <tr style={buttonIsh}>
          { cells(model, dispatch) }
        </tr>
      </thead>
    );
  }
};

const cells = (model, dispatch) => {
  if (canSelectSort(model)) {
    return cellConfigs(model).map((config) => {
      return(
        <SortableTableHeadingCell
          model={model}
          dispatch={dispatch}
          label={config.label}
          key={config.key}
          headingKey={config.key}
        />
      );
    })
  }
  else {
    return cellConfigs(model).map((config) => {
      return(
        <th className={classname(model, config.key)} key={config.key}>
          { config.label }
        </th>
      );
    });
  }
}

const classname = (model, headingKey) => {
  return [
    "datatable__th",
    classnamePrefix(model),
    headingKey.toLowerCase()
  ].filter((elem) => elem !== "").join("--");
}

const classnamePrefix = ((model) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    return "referents";
  }
  else if (collectionShownName(model) === "contentItem") {
    return "content-items";
  }
  else {
    return "";
  }
}).pwPipe(memoizePerRender)

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
  else if (matchedRoute(model) === "/news_items"){
    return [
      { label: "Title", key: "TITLE" },
      { label: "Division", key: "DIVISION"},
      { label: "Type", key: "TYPE"},
      { label: "Date", key: "DATE"},
      { label: "", key: "ADMIN"}
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
  else if (matchedRoute(model) === "/issues"){
    return [
      { label: "#", key: "ID" },
      { label: "Description", key: "DESCRIPTION" },
      { label: "Source", key: "SOURCE" }
    ];
  }
};

const SortableTableHeadingCell = ({model, dispatch, label, headingKey}) => {
  const onClick = _.partial(
    sortByHeading,
    dispatch,
    headingKey,
    selectedTableHeadingKey(model),
    model
  );

  return(
    <th onClick={onClick}
      className={classname(model, headingKey)}
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
