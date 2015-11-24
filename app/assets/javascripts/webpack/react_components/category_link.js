import React from "react";

const CategoryLink = (props) => {
  return(
    <div>
      <i className='icon-arrow-right icon-blue' style={{marginRight: "5px"}}></i>
      <a href={props.link}>{props.text}</a>
    </div>
  );
};

export default CategoryLink;
