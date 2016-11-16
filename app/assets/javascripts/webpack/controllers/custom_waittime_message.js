import React from "react";
import { useProcedureSpecificWaitTimes } from "controller_helpers/procedure_specific_wait_times";

const CustomWaittimeMessage = ({model}) => {
  if(useProcedureSpecificWaitTimes(model)){
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
