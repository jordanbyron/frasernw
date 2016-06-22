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
import { buttonIsh } from "stylesets";
import _ from "lodash";
import ExpandRowsToggle from "controllers/expand_rows_toggle";

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
  let _classnamePrefix = classnamePrefix(model);

  return cellConfigs(model, dispatch).map((config) => {
    return(
      <TableHeadingCell
        model={model}
        dispatch={dispatch}
        label={config.label}
        key={config.key}
        showExpansionToggle={config.showExpansionToggle}
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

const cellConfigs = (model, dispatch) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    var configs = [
      { label: collectionShownPluralLabel(model), key: "NAME", showExpansionToggle: true},
      { label: "Accepting New Referrals?", key: "REFERRALS" },
      { label: "Average Non-urgent Patient Waittime", key: "WAITTIME"},
      { label: "City", key: "CITY" }
    ];

    if (showingMultipleSpecializations(model)){
      configs.splice(0, 1, { label: "Specialties", key: "SPECIALTIES" })
    }

    return configs;
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
};

const TableHeadingCell = ({
  model,
  dispatch,
  label,
  headingKey,
  classnamePrefix,
  showExpansionToggle
}) => {
  const onClick = _.partial(
    sortByHeading,
    dispatch,
    headingKey,
    selectedTableHeadingKey(model),
    model
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
      <ExpandRowsToggle
        model={model}
        dispatch={dispatch}
        shouldShow={showExpansionToggle}
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
