import React from "react";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import SharedCareIcon from "component_helpers/icons/shared_care";
import FavoriteIcon from "controllers/icons/favorite";
import EmailIcon from "component_helpers/icons/email";
import FeedbackIcon from "controllers/icons/feedback";
import HideToggle from "controllers/hide_toggle";
import HiddenBadge from "component_helpers/hidden_badge";
import NewsItemRow from "controllers/table_row/news_item";
import * as filterValues from "controller_helpers/filter_values";
import { selectRecord, deselectRecord } from "action_creators";
import { memoizePerRender } from "utils";
import ChangeRequestRow from "controllers/table_row/change_request";
import EntityPageViewRow from "controllers/table_row/entity_page_view";
import IssueRow from "controllers/table_row/issue";
import ReferentRow from "controllers/table_row/referent";
import Tags from "controllers/tags";

const TableRow = ({model, dispatch, decoratedRecord}) => {
  if(_.includes([
    "/specialties/:id",
    "/areas_of_practice/:id",
    "/content_categories/:id",
    "/hospitals/:id",
    "/languages/:id"
  ], route)) {
    if(_.includes(["specialists", "clinics"], collectionShownName(model))) {
      return(
        <ReferentRow
          model={model}
          dispatch={dispatch}
          decoratedRecord={decoratedRecord}
        />
      );
    }
    else if (collectionShownName(model) === "contentItems"){
      return(
        <tr>
          <ContentItemTitle decoratedRecord={decoratedRecord} model={model}/>
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
  else if (route === "/reports/referents_by_specialty" &&
    filterValues.reportStyle(model) === "summary") {

    return(
      <tr key={decoratedRecord.raw.id}>
        <td key="name">{ decoratedRecord.raw.name } </td>
        <td key="count">{ decoratedRecord.count }</td>
      </tr>
    );
  }
  else if (route === "/reports/entity_page_views") {
    return(
      <EntityPageViewRow decoratedRecord={decoratedRecord} model={model}/>
    );
  }
  else if (route === "/reports/page_views_by_user") {
    return(
      <tr>
        <td key="name">
          <a href={`/users/${decoratedRecord.raw.id}`}>{decoratedRecord.raw.name}</a>
        </td>
        <td key="views">{decoratedRecord.raw.pageViews}</td>
      </tr>
    );
  }
  else if (route === "/latest_updates"){
    var className = "latest_updates__update"
    if (model.ui.persistentConfig.canHide){
      className += " latest_updates__update--editable";
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
  else if (route === "/news_items") {
    return(
      <NewsItemRow
        decoratedRecord={decoratedRecord}
        model={model}
        dispatch={dispatch}
      />
    );
  }
  else if (route === "/issues"){
    return(<IssueRow decoratedRecord={decoratedRecord} model={model}/>);
  }
  else if (route === "/change_requests"){
    return(<ChangeRequestRow decoratedRecord={decoratedRecord} model={model}/>);
  }
};

const ContentItemTitle = ({decoratedRecord, model}) => {
  return(
    <td>
      <span>
        <SharedCareIcon color="blue" shouldDisplay={decoratedRecord.raw.isSharedCare}/>
        <a
          href={decoratedRecord.raw.resolvedUrl}
          target="_blank"
          onClick={function() { window.pathways.trackContentItem(_gaq, decoratedRecord.raw.id) }}
        >{ decoratedRecord.raw.title }</a>
        <Tags record={decoratedRecord.raw} model={model}/>
      </span>
    </td>
  )
}

export default TableRow;
