import React from "react";
import { buttonIsh } from "stylesets";

const SharedCareIcon = ({shouldDisplay, color}) => {
  if (shouldDisplay) {
    return(<i className={`icon-star icon-${color}`} style={{marginRight: "5px"}}/>);
  } else {
    return <noscript/>;
  }
}

export default SharedCareIcon;
