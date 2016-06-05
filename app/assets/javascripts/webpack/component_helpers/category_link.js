import React from "react";

const CategoryLink = ({url, label}) => {
  return(
    <div>
      <i className='icon-arrow-right icon-blue' style={{marginRight: "5px"}}></i>
      <a href={url}>{label}</a>
    </div>
  );
};

export default CategoryLink;
