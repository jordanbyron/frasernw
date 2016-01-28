import React from 'react';

const SidebarWellSection = ({title, children}) => {
  return(
    <div>
      <div className="filter_group__title open" key="title">{title}</div>
      <div className="filter_group__filters"
        key="contents"
      >
        { children }
      </div>
    </div>
  )
}

export default SidebarWellSection;
