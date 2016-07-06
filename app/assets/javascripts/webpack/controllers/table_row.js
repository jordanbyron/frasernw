import React from "react";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import Tags from "component_helpers/tags";
import ReferentStatusIcon from "controllers/referent_status_icon";
import showingMultipleSpecializations
  from "controller_helpers/showing_multiple_specializations";
import SharedCareIcon from "component_helpers/icons/shared_care";
import FavoriteIcon from "controllers/icons/favorite";
import EmailIcon from "component_helpers/icons/email";
import FeedbackIcon from "controllers/icons/feedback";
import HideToggle from "controllers/hide_toggle";
import HiddenBadge from "component_helpers/hidden_badge";
import NewsItemRow from "controllers/table_row/news_items";
import * as filterValues from "controller_helpers/filter_values";
import { memoizePerRender } from "utils";
import ChangeRequestRow from "controllers/table_row/change_request";
import EditIssue from "controllers/icons/edit_issue";
import IssueRow from "controllers/table_row/issues";


const TableRow = ({model, dispatch, decoratedRecord}) => {
  if(_.includes([
    "/specialties/:id",
    "/areas_of_practice/:id",
    "/content_categories/:id",
    "/hospitals/:id",
    "/languages/:id"
  ], matchedRoute(model))) {
    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      if(showingMultipleSpecializations(model)) {
        return(
          <tr className={decoratedRecord.raw.hidden ? "hidden-from-users" : ""}>
            <ReferentName decoratedRecord={decoratedRecord} model={model}/>
            <ReferentSpecializations decoratedRecord={decoratedRecord} model={model}/>
            <td><ReferentStatusIcon model={model} record={decoratedRecord.raw} tooltip={true}/></td>
            <td>{ decoratedRecord.waittime }</td>
            <td>{ decoratedRecord.cityNames }</td>
          </tr>
        );
      }
      else {
        return(
          <tr className={decoratedRecord.raw.hidden ? "hidden-from-users" : ""}>
            <ReferentName decoratedRecord={decoratedRecord} model={model}/>
            <td><ReferentStatusIcon model={model} record={decoratedRecord.raw} tooltip={true}/></td>
            <td>{ decoratedRecord.waittime }</td>
            <td>{ decoratedRecord.cityNames }</td>
          </tr>
        );
      }
    }
    else if (collectionShownName(model) === "contentItems"){
      return(
        <tr>
          <ContentItemTitle decoratedRecord={decoratedRecord}/>
          <td>{ decoratedRecord.subcategoryName }</td>
          <td>
            <FavoriteIcon
              record={decoratedRecord.raw}
              dispatch={dispatch}
              model={model}
            />
          </td>
          <td><EmailIcon record={decoratedRecord.raw}/></td>
          <td><FeedbackIcon record={decoratedRecord.raw} dispatch={dispatch}/></td>
        </tr>
      );
    }
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty" &&
    filterValues.reportStyle(model) === "summary") {

    return(
      <tr key={decoratedRecord.raw.id}>
        <td key="name">{ decoratedRecord.raw.name } </td>
        <td key="count">{ decoratedRecord.count }</td>
      </tr>
    );
  }
  else if (matchedRoute(model) === "/reports/entity_page_views") {
    return(
      <tr key={decoratedRecord.reactKey}>
        <td dangerouslySetInnerHTML={{__html: decoratedRecord.raw.link}}/>
        <td key="count">{ decoratedRecord.raw.usage }</td>
      </tr>
    )
  }
  else if (matchedRoute(model) === "/reports/pageviews_by_user") {
    return(
      <tr>
        <td key="name">
          <a href={`/users/${decoratedRecord.raw.id}`}>{decoratedRecord.raw.name}</a>
        </td>
        <td key="views">{decoratedRecord.raw.pageViews}</td>
      </tr>
    );
  }
  else if (matchedRoute(model) === "/latest_updates"){
    if (model.ui.persistentConfig.canHide){
      var className = "latest_updates__update--editable";
    }
    else {
      var className = "";
    }

    return(
      <tr>
        <td className={className}>
          <div className="latest_updates__update_text">
            <span dangerouslySetInnerHTML={{__html: decoratedRecord.raw.markup}}/>
            <HiddenBadge isHidden={decoratedRecord.raw.hidden}/>
          </div>
          <HideToggle update={decoratedRecord.raw} model={model} dispatch={dispatch}/>
        </td>
      </tr>
    )
  }
  else if (matchedRoute(model) === "/news_items") {
    return(
      <NewsItemRow
        decoratedRecord={decoratedRecord}
        model={model}
        dispatch={dispatch}
      />
    );
  }
  else if (matchedRoute(model) === "/issues"){
    return(<IssueRow decoratedRecord={decoratedRecord} model={model}/>);
  }
  else if (matchedRoute(model) === "/change_requests"){
    return(<ChangeRequestRow decoratedRecord={decoratedRecord} model={model}/>);
  }
};

const ContentItemTitle = ({decoratedRecord}) => {
  return(
    <td>
      <span>
        <SharedCareIcon color="blue" shouldDisplay={decoratedRecord.raw.isSharedCare}/>
        <a
          href={decoratedRecord.raw.resolvedUrl}
          target="_blank"
          onClick={function() { window.pathways.trackContentItem(_gaq, decoratedRecord.raw.id) }}
        >{ decoratedRecord.raw.title }</a>
        <Tags record={decoratedRecord.raw}/>
      </span>
    </td>
  )
}

const ReferentSpecializations = ({decoratedRecord}) => {
  return(<td>{decoratedRecord.specializationNames}</td>);
}

const ReferentName = ({decoratedRecord, model}) => {
  return (
    <td>
      <span>
        <a href={"/" + decoratedRecord.raw.collectionName + "/" + decoratedRecord.raw.id}>
          { decoratedRecord.raw.name }
        </a>
        <Suffix record={decoratedRecord.raw} model={model}/>
        <Tags record={decoratedRecord.raw}/>
      </span>
    </td>
  );
}

const Suffix = ({record, model}) => {
  return(
    <span style={{marginLeft: "5px"}} className="suffix" key="suffix">
      {suffix(record, model)}
    </span>
  )
}

const suffix = (record, model) => {
  if (record.collectionName === "clinics") {
    return "";
  }
  else if (record.isGp) {
    return "GP";
  }
  else if (record.isInternalMedicine) {
    return "Int Med";
  }
  else if (showPedSuffix(record, model)) {
    return "Ped";
  }
  else {
    return _.find(
      record.specializationIds.map((id) => model.app.specializations[id].suffix),
      (suffix) => suffix && suffix.length > 0
    );
  }
};


const showPedSuffix = (record, model) => {
  return record.seesOnlyChildren &&
    record.specializationIds.length > 1 &&
    isPediatrician(record, model) &&
    (matchedRoute(model) !== "/specialties/:id" ||
      recordShownByPage(model).id !== parseInt(pediatricsId(model)));
}

const pediatricsId = ((model) => {
  return _.find(
    model.app.specializations,
    (specialization) => specialization.name === "Pediatrics"
  ).id;
}).pwPipe(memoizePerRender)

const isPediatrician = (record, model) => {
  return _.includes(record.specializationIds, parseInt(pediatricsId(model)));
}

export default TableRow;
