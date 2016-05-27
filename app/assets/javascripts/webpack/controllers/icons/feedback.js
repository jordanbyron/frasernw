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
          record.id,
          transformCollectionName(record.collectionName),
          record.title
        )
      }
      title="Provide feedback on this item"
    />
  );
};

const transformCollectionName = (collectionName) => {
  if (collectionName === "contentItem"){
    return "ScItem";
  }
}

export default FeedbackIcon;
