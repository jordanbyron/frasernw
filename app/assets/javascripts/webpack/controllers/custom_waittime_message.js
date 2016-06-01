import React from "react";
import { shouldUseCustomWaittime } from "controller_helpers/custom_waittimes";

const CustomWaittimeMessage = ({model}) => {
  if(shouldUseCustomWaittime(model)){
    return(
      <div className="alert alert-info">
        <i className="icon-link" style={{marginRight: "5px"}}/>
        <span>
          {
            "You have chosen an area of practice with a specific wait time. " +
            "The wait time column has been updated accordingly."
          }
        </span>
      </div>
    )
  }
  else {
    return <noscript/>
  }
}

export default CustomWaittimeMessage;
