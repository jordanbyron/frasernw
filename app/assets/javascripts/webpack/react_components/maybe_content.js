import React from "react";

const MaybeContent = (props) => {
  console.log(props);
  if(props.shouldDisplay){
    console.log("hey");
    return props.contents();
  }
  else {
    return <div></div>;
  }
}

export default MaybeContent;
