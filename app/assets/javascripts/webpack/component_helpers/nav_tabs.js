import React from "react";

export function NavTabs({children}){
  return(
    <ul className="nav nav-tabs">
      { children }
    </ul>
  )
};

export function NavTab({label, onClick, isSelected}){
  const className = isSelected ? "active" : ""

  return(
    <li onClick={onClick}
      className={className}
    >
      <a>{ label }</a>
    </li>
  );
};
