import React from "react";
import { selectedTableHeadingKey, headingArrowDirection, canSelectSort }
  from "controller_helpers/table_headings";
import { sortByHeading } from "action_creators";
import { route } from "controller_helpers/routing";
import { collectionShownPluralLabel, collectionShownName }
  from "controller_helpers/collection_shown";
import { entityType } from "controller_helpers/filter_values";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import { buttonIsh } from "stylesets";
import _ from "lodash";
import ExpandRowsToggle from "controllers/expand_rows_toggle";
import { memoizePerRender } from "utils";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const TableHeadings = ({model, dispatch}) => {
  if(_.includes(["/reports/entity_page_views", "/latest_updates"], route)){
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
  return cellConfigs(model, dispatch).map((config) => {
    return(
      <TableHeadingCell
        model={model}
        dispatch={dispatch}
        label={config.label}
        key={config.key}
        showExpansionToggle={config.showExpansionToggle}
        headingKey={config.key}
      />
    );
  })
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

const cellConfigs = (model, dispatch) => {
  if (_.includes(["specialists", "clinics"], collectionShownName(model))){
    var configs = [
      { label: collectionShownPluralLabel(model), key: "NAME", showExpansionToggle: true},
      { label: "Accepting New Referrals?", key: "REFERRALS" },
      { label: "Average Non-urgent Patient Waittime", key: "WAITTIME"},
      { label: "City", key: "CITY" }
    ];

    if (showingMultipleSpecializations(model)){
      configs.splice(1, 0, { label: "Specialties", key: "SPECIALTIES" })
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
  else if (route === "/news_items"){
    return [
      { label: "Title", key: "TITLE" },
      { label: "Division", key: "DIVISION"},
      { label: "Type", key: "TYPE"},
      { label: "Date", key: "DATE"},
      { label: "", key: "ADMIN"}
    ];
  }
  else if (route === "/reports/page_views_by_user"){
    return [
      { label: "User", key: "USERS" },
      { label: "Page Views", key: "PAGE_VIEWS" }
    ];
  }
  else if (route === "/reports/referents_by_specialty"){
    return [
      { label: "Specialty", key: "SPECIALTY" },
      { label: _.capitalize(entityType(model)), key: "ENTITY_TYPE" }
    ];
  }
  else if (route === "/issues"){
    return [
      { label: "Code", key: "ISSUE_CODE" },
      { label: "Title", key: "DESCRIPTION" }
    ];
  }
  else if (route === "/change_requests"){
    if (selectedTabKey(model) === "pendingIssues"){
      if(model.ui.persistentConfig.showIssueEstimates){
        return [
          { label: "#", key: "ID" },
          { label: "Title", key: "DESCRIPTION" },
          { label: "Date Entered", key: "DATE_ENTERED"},
          { label: "Priority", key: "PRIORITY" },
          { label: "Effort", key: "EFFORT" },
          { label: "Progress", key: "PROGRESS" },
          { label: "Estimated Completion Date", key: "ESTIMATE" }
        ];
      }
      else {
        return [
          { label: "#", key: "ID" },
          { label: "Title", key: "DESCRIPTION" },
          { label: "Date Entered", key: "DATE_ENTERED"},
          { label: "Priority", key: "PRIORITY" },
          { label: "Effort", key: "EFFORT" },
          { label: "Progress", key: "PROGRESS" },
        ];
      }
    }
    else {
      return [
        { label: "#", key: "ID" },
        { label: "Title", key: "DESCRIPTION" },
        { label: "Date Entered", key: "DATE_ENTERED"},
        { label: "Date Completed", key: "DATE_COMPLETED" }
      ];
    }
  }
};

const TableHeadingCell = ({
  model,
  dispatch,
  label,
  headingKey,
  showExpansionToggle
}) => {
  return(
    <th onClick={onTableHeadingClick(model, dispatch, headingKey)}
      className={classname(model, headingKey)}
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

const onTableHeadingClick = (model, dispatch, headingKey) => {
  if(canSelectSort(model)){
    return _.partial(
      sortByHeading,
      dispatch,
      headingKey,
      selectedTableHeadingKey(model),
      model
    );
  }
  else {
    return _.noop
  }
}

const TableHeadingArrow = ({model, headingKey}) => {
  if (canSelectSort(model) && selectedTableHeadingKey(model) === headingKey) {
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

export default TableHeadings;
