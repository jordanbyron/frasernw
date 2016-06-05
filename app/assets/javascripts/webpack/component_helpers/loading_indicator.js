import React from "react";

const LoadingIndicator = ({minHeight}) => {
  return(
    <div style={{position: "relative", minHeight: minHeight}}>
      <div id="heartbeat-loader-position-noremove" style={{position: "absolute"}}>
        <div className="heartbeat-loader"/>
      </div>
    </div>
  );
};

export default LoadingIndicator;
