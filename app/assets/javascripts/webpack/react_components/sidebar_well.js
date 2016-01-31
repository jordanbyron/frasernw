import React from 'react';

const SidebarWell = ({title, children}) => {
  return(
    <div className="well filter">
      <div className="title" key="title">{ title }</div>
      { children }
    </div>
  );
}

export default SidebarWell;
