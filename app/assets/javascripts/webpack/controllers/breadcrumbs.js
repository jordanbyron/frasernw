import React from "react";
import recordShown from "controller_helpers/record_shown";
import { matchedRoute } from "controller_helpers/routing";
import { toggleBreadcrumbDropdown, changeRoute } from "action_creators";

const Breadcrumbs = ({model, dispatch}) => {
  return(
    <div>
      <ul id="specialties-menu">
        <li className="dropdown" onClick={_.partial(
          toggleBreadcrumbDropdown,
          dispatch,
          dropdownIsOpen(model))}
        >
          <a className="specialties-dropdown-toggle" href="javascript:void(0)">
            <span>All Specialties</span>
            <b className="caret"/>
          </a>
        </li>
        <ParentSpecialtyBreadcrumb model={model}/>
        <ParentProcedureBreadcrumb model={model} level={-2}/>
        <ParentProcedureBreadcrumb model={model} level={-1}/>
        <RecordShownBreadcrumb model={model}/>
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
      <div id="specialties-dropdown-menu"
        className="specialties_dropdown_menu--react">
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
              <a href="javascript:void(0)"
                className={inProgressClass(model, specialization)}
                onClick={_.partial(
                    changeRoute,
                    dispatch,
                    `/specialties/${specialization.id}`
                  )
                }
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

const ParentSpecialtyBreadcrumb = ({model}) => {
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    const names = recordShown(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (recordShown(model).specializationIds.length > 2) {
      var label = `${names.join(", ")}...`;
    }
    else {
      var label = names.join(", ");
    }


    return(
      <li className="subsequent specialty">
        <span>{ label }</span>
      </li>
    );
  }
  else {
    return <span></span>;
  }
};

const ParentProcedureBreadcrumb = ({model, level}) => {
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    const names = recordShown(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (level === -1) {
      var className = "parent";
    }
    else {
      var className = "grandparent";
    }

    const procedureIdIndex = recordShown(model).ancestorIds.length + level;
    const procedureId = recordShown(model).ancestorIds[procedureIdIndex];

    if (procedureId) {
      return(
        <li className={`subsequent ${className}`}>
          <span>
            { model.app.procedures[procedureId].name }
          </span>
        </li>
      );
    }
    else {
      return <span></span>;
    }
  }
  else {
    return <span></span>;
  }
}

const RecordShownBreadcrumb = ({model}) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return(
      <li className={`subsequent ${inProgressClass(model, recordShown(model))}`}>
        <span>{ recordShown(model).name }</span>
        <NewTag model={model} specialization={recordShown(model)}/>
      </li>
    );
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    return(
      <li className="subsequent">
        <span>{ recordShown(model).name }</span>
      </li>
    );
  }
  else {
    return <span></span>;
  }
};

export default Breadcrumbs;
