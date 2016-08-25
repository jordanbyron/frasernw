import React from "react";

export function NavTabs({children}){
  return(
    <ul className="nav nav-tabs">
      { children }
    </ul>
  )
};

export function NavTab({label, onClick, isSelected, doesPageNav, href}){
  const className = isSelected ? "active" : ""

  if(doesPageNav){
    return(
      <li className={className}>
        <a href={href}>{ label }</a>
      </li>
    )
  }
  else {
    return(
      <li onClick={onClick}
        className={className}
      >
        <a>{ label }</a>
      </li>
    );
  }
};
