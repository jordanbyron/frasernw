import React from "react";

const CategoryLink = (props) => {
  if(props.link && props.text) {
    return(
      <div>
        <hr/>
        <i className='icon-arrow-right icon-blue' style={{marginRight: "5px"}}></i>
        <a href={props.link}>{props.text}</a>
      </div>
    );
  }
  else {
    return <div></div>;
  }
};

export default CategoryLink;
