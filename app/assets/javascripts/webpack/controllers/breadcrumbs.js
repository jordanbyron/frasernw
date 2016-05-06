import React from "react";
import recordShown from "controller_helpers/record_shown";

const BreadcrumbsController = ({model, dispatch}) => {
  return(
    <ul className="specialties-menu">
      <li className="dropdown">
        <a className="specialties-dropdown-toggle" href="javascript:void(0)">
          <span>All Specialties</span>
          <b className="caret"/>
        </a>
      </li>
      <SecondBreadcrumb model={model}/>
    </ul>
  );
}

const NewTag = ({model}) => {
  const showAsNew = _.some(model.currentUser.divisionIds, (id) => {
    return _.includes(recordShown(model).newInDivisionIds, id);
  })

  if (showAsNew){
    return <span className="new"/>
  } else {
    return <span/>
  }
}

const inProgress = (model) => {
  if (matchedRoute(model) !== "/specialties/:id"){
    return false;
  }
  else {
    return _.every(model.currentUser.divisionIds, (id) => {
      return _.includes(recordShown(model).inProgressInDivisionIds, id);
    })
  }
};

const inProgressClass = (model) => {
  if (inProgress(model)) {
    return "in-progress";
  }
  else {
    return "";
  }
}

const SecondBreadcrumb = ({model}) => {
  return(
    <li className={`subsequent ${inProgressClass(model)}`}>
      <span>{ recordShown(model).name }</span>
      <NewTag model={model}/>
    </li>
  );
};

export default BreadcrumbsController;
