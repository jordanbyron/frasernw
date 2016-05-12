import React from "react";
import recordShown from "controller_helpers/record_shown";
import { matchedRoute } from "controller_helpers/routing";
import { toggleBreadcrumbDropdown } from "action_creators";

const Breadcrumbs = ({model, dispatch}) => {
  return(
    <div>
      <ul id="specialties-menu">
        <li className="dropdown" onClick={_.partial(toggleBreadcrumbDropdown, dispatch, dropdownIsOpen(model))}>
          <a className="specialties-dropdown-toggle" href="javascript:void(0)">
            <span>All Specialties</span>
            <b className="caret"/>
          </a>
        </li>
        <SecondBreadcrumb model={model}/>
      </ul>
      <BreadcrumbDropdown model={model} dispatch={dispatch}/>
    </div>
  );
}

const dropdownIsOpen = (model) => {
  return _.get(model, [ "ui", "openBreadcrumbDropdown" ], false);
}

const BreadcrumbDropdown = ({model, dispatch}) => {
  if(dropdownIsOpen(model)) {
    const height = _.ceil(model.app.specializations.length / 4);

    return (
      <div id="specialties-dropdown-menu" className="specialties_dropdown_menu--react">
        <div className="inner">
          {
            _.range(1, 5).map((columnNumber) => {
              return(
                <BreadcrumbDropdownColumn
                  model={model}
                  dispatch={dispatch}
                  columnNumber={columnNumber}
                  key={columnNumber}
                />
              );
            })
          }
        </div>
      </div>
    );
  }
  else {
    return(<span></span>);
  }
};

const breadcrumbDropdownHeight = (model) => {
  return _.ceil(_.values(model.app.specializations).length / 4);
}

const BreadcrumbDropdownColumn = ({model, dispatch, columnNumber}) => {
  const specializations = _.values(model.app.specializations)
    .pwPipe((specializations) => _.sortBy(specializations, "name") )
    .slice(
      (breadcrumbDropdownHeight(model) * (columnNumber - 1)),
      (breadcrumbDropdownHeight(model) * columnNumber)
    )

  return(
    <ul>
      {
        specializations.map((specialization) => {
          return(
            <li key={specialization.id}>
              <a href={`/specialties/${specialization.id}`}
                className={inProgressClass(model, specialization)}
              >
                <span>{ specialization.name } </span>
                <NewTag model={model}
                  specialization={specialization}
                />
              </a>
            </li>
          );
        })
      }
    </ul>
  );
}

const NewTag = ({model, specialization}) => {
  const showAsNew = _.some(model.app.currentUser.divisionIds, (id) => {
    return _.includes(specialization.newInDivisionIds, id);
  })

  if (showAsNew){
    return <span className="new"/>
  } else {
    return <span/>
  }
}

const inProgress = (model, specialization) => {
  if (matchedRoute(model) !== "/specialties/:id"){
    return false;
  }
  else {
    return _.every(model.app.currentUser.divisionIds, (id) => {
      return _.includes(specialization.inProgressInDivisionIds, id);
    })
  }
};

const inProgressClass = (model, specialization) => {
  if (inProgress(model, specialization)) {
    return "in-progress";
  }
  else {
    return "";
  }
}

const SecondBreadcrumb = ({model}) => {
  return(
    <li className={`subsequent ${inProgressClass(model, recordShown(model))}`}>
      <span>{ recordShown(model).name }</span>
      <NewTag model={model} specialization={recordShown(model)}/>
    </li>
  );
};

export default Breadcrumbs;
