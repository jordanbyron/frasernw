import React from "react";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import Tags from "component_helpers/tags";
import ReferentStatusIcon from "controllers/referent_status_icon";
import { showingOtherSpecializations } from "controller_helpers/filter_messages";
import SharedCareIcon from "component_helpers/icons/shared_care";
import FavoriteIcon from "controllers/icons/favorite";
import EmailIcon from "component_helpers/icons/email";
import FeedbackIcon from "controllers/icons/feedback";
import * as filterValues from "controller_helpers/filter_values";


const TableRow = ({model, dispatch, decoratedRecord}) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id", "/content_categories/:id"],
    matchedRoute(model))) {

    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      if(showingOtherSpecializations(model)) {
        return(
          <tr>
            <ReferentName decoratedRecord={decoratedRecord}/>
            <ReferentSpecializations decoratedRecord={decoratedRecord} model={model}/>
            <td><ReferentStatusIcon model={model} record={decoratedRecord.raw}/></td>
            <td>{ labelReferentWaittime(decoratedRecord.raw, model) }</td>
            <td>{ decoratedRecord.cityNames }</td>
          </tr>
        );
      }
      else {
        return(
          <tr>
            <ReferentName decoratedRecord={decoratedRecord}/>
            <td><ReferentStatusIcon model={model} record={decoratedRecord.raw}/></td>
            <td>{ labelReferentWaittime(decoratedRecord.raw, model) }</td>
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
};


const ContentItemTitle = ({decoratedRecord}) => {
  return(
    <td>
      <span>
        <SharedCareIcon color="blue" shouldDisplay={decoratedRecord.raw.isSharedCare}/>
        <a
          href={decoratedRecord.raw.resolvedUrl}
          target="_blank"
          onClick={function() { trackContentItem(_gaq, decoratedRecord.raw.id) }}
        >{ decoratedRecord.raw.title }</a>
        <Tags record={decoratedRecord.raw}/>
      </span>
    </td>
  )
}

const ReferentSpecializations = ({decoratedRecord}) => {
  return(<td>{decoratedRecord.specializationNames}</td>);
}

const ReferentName = ({decoratedRecord}) => {
  return (
    <td>
      <span>
        <a href={"/" + decoratedRecord.raw.collectionName + "/" + decoratedRecord.raw.id}>
          { decoratedRecord.raw.name }
        </a>
        <span  style={{marginLeft: "5px"}} className="suffix" key="suffix">
          { decoratedRecord.raw.suffix }
        </span>
        <Tags record={decoratedRecord.raw}/>
      </span>
    </td>
  );
}


const customWaittimeProcedureId = (model) => {
  // return activatedProcedures[0];

  return 0;
}

const shouldUseCustomWaittime = (model) => {
  // return (activatedProcedures.length === 1 &&
  //   nestedProcedureIds[activatedProcedures[0]].customWaittime[panelTypeKey]),

  return false;
}

const labelReferentWaittime = (record, model) => {
  if(shouldUseCustomWaittime(model)){
    return (model.waittimeHash[record.customWaittimes[customWaittimeProcedureId(model)]] || "");
  } else {
    return (record.waittime || "");
  }
};

export default TableRow;
