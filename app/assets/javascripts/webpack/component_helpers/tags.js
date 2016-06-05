import React from "react";

const Tags = ({record}) => {
  let tags = [];

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
