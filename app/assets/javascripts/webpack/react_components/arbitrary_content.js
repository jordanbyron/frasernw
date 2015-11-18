import React from "react";
import _ from "lodash";

const ArbitraryContent = (props) => {
  if(!_.isUndefined(props.contents)){
    return props.contents;
  }
  else {
    return <div></div>;
  }
};

export default ArbitraryContent;
