import React from 'react';

const FilterGroup = ({title, children}) => {
  return(
    <div>
      <div className="filter_group__title">{title}</div>
      <div className="filter_group__filters">
        { children }
      </div>
    </div>
  );
}

export default FilterGroup;
