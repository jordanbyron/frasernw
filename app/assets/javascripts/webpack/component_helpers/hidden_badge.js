import React from "react";

const HiddenBadge = ({isHidden}) => {
  if(isHidden){
    return(
      <span className="label label-default" style={{marginLeft: "10px"}}>
        {"Hidden"}
      </span>
    )
  }
  else {
    return <span></span>;
  }
}

export default HiddenBadge;
