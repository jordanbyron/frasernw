import React from "react";

const MaybeContent = (props) => {
  if(props.shouldDisplay){
    return props.contents();
  }
  else {
    return <span></span>;
  }
}

export default MaybeContent;
