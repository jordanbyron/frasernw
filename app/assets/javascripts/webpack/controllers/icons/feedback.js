import React from "react";
import { buttonIsh } from "stylesets";
import { openFeedbackModal } from "action_creators"
import _ from "lodash";

const FeedbackIcon = ({record, dispatch}) => {
  return(
    <i className="icon-bullhorn icon-blue"
      style={buttonIsh}
      onClick={
        _.partial(
          openFeedbackModal,
          dispatch,
          {
            id: record.id,
            klass: transformCollectionName(record.collectionName),
            label: record.title
          }
        )
      }
      title="Provide feedback on this item"
    />
  );
};

const transformCollectionName = (collectionName) => {
  if (collectionName === "contentItems"){
    return "ScItem";
  }
}

export default FeedbackIcon;
