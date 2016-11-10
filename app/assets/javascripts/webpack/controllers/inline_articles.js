import React from "react";
import { isTabbedPage, recordShownByTab } from "controller_helpers/nav_tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";
import { recordShownByRoute } from "controller_helpers/routing";
import SharedCareIcon from "component_helpers/icons/shared_care";
import FavoriteIcon from "controllers/icons/favorite";
import FeedbackIcon from "controllers/icons/feedback";
import recordsToDisplay from "controller_helpers/records_to_display";

const InlineArticles = ({model, dispatch}) => {
  if(shouldShow(model)){

    return(
      <div>
        {
          recordsToDisplay(model).map((resource) => {
            return(
              <InlineArticle
                key={resource.id}
                record={resource}
                model={model}
                dispatch={dispatch}
              />
            )
          })
        }
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const InlineArticle = ({record, model, dispatch}) => {
  return(
    <div className="scm">
      <h1>
        <SharedCareIcon shouldDisplay={ record.isSharedCare } color="red"/>
        <span>{ record.title }</span>
        <FavoriteIcon record={record} model={model} dispatch={dispatch}/>
        <FeedbackIcon record={record} dispatch={dispatch}/>
      </h1>
      <div dangerouslySetInnerHTML={{__html: record.content}}/>
    </div>
  );
}

const CategoryLink = ({record, model}) => {

}

const shouldShow = (model) => {
  return collectionShownName(model) === "contentItems" &&
    ((isTabbedPage(model) && recordShownByTab(model).componentType === "InlineArticles") ||
    (!isTabbedPage(model) && recordShownByRoute(model).componentType === "InlineArticles"))
}

export default InlineArticles;
