import React from "react";
import { route, recordShownByRoute } from "controller_helpers/routing";

const Tags = ({record, model}) => {
  let tags = [];

  if (record.collectionName === "specialists" && record.taggedSpecializationId){
    if ((route === "/specialties/:id" &&
      record.taggedSpecializationId !== recordShownByRoute(model).id) ||
      (model.app.specializations[record.taggedSpecializationId].globalMemberTag)){

      tags.push(
        <span style={{marginLeft: "5px"}} className="suffix" key="suffix">
          { model.app.specializations[record.taggedSpecializationId].memberTag }
        </span>
      )
    }
  }

  if (record.isNew){
    tags.push(
      <span style={{marginLeft: "5px"}} className="new" key="new">new</span>
    );
  }

  if (record.isPrivate && !record.isPublic){
    tags.push(
      <span style={{marginLeft: "5px"}} className="private" key="isPrivate">
        private
      </span>
    );
  }

  return(<span>{tags}</span>);
}

export default Tags;
