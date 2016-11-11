import React from "react";
import ReactDOM from "react-dom";
import { recordShownByRoute, route } from "controller_helpers/routing";
import hiddenFromUsers from "controller_helpers/hidden_from_users";
import _ from "lodash";
import { buttonIsh} from "stylesets";
import { toggleBreadcrumbDropdown } from "action_creators";
import { recordShownByBreadcrumb } from "controller_helpers/breadcrumbs";

const ROUTES_SHOWING = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/clinics/:id",
  "/specialists/:id",
  "/faq_categories/:id",
  "/referral_forms",
  "/content_items/:id",
  "/terms_and_conditions",
  "/"
];

const Breadcrumbs = React.createClass({
  componentDidMount: function() {
    document.addEventListener("click", (e) => {
      var domNode = ReactDOM.findDOMNode(this);
      var component = this;
      if((!domNode || !domNode.contains(e.target)) &&
        dropdownIsOpen(component.props.model)){

        toggleBreadcrumbDropdown(this.props.dispatch, false)
      }

      return true;
    })
  },
  render: function() {
    if (_.includes(ROUTES_SHOWING, route)){
      return(
        <div style={{position: "relative"}}>
          <ul id="specialties-menu">
            <li className={dropdownClassName(this.props.model)}>
              <a className="specialties-dropdown-toggle"
                onClick={_.partial(
                  toggleBreadcrumbDropdown,
                  this.props.dispatch,
                  !dropdownIsOpen(this.props.model)
                )}
                href="javascript:void(0)"
                style={buttonIsh}>
                <span>All Specialties </span>
                <b className="caret"/>
              </a>
            </li>
            <ParentSpecialtyBreadcrumb model={this.props.model}/>
            <ParentProcedureBreadcrumb model={this.props.model} level={-2}/>
            <ParentProcedureBreadcrumb model={this.props.model} level={-1}/>
            <ChildBreadcrumb model={this.props.model}/>
          </ul>
          <BreadcrumbDropdown
            model={this.props.model}
            dispatch={this.props.dispatch}
          />
        </div>
      );
    }
    else {
      return <span></span>;
    }
  }
})

const dropdownClassName = (model) => {
  if(_.includes([
    "/specialties/:id",
    "/areas_of_practice/:id",
    "/content_items/:id",
    "/specialists/:id",
    "/clinics/:id"
  ], route)){

    return "dropdown";
  }
  else {
    return "dropdown no-caret";
  }
}

const dropdownIsOpen = (model) => {
  return _.get(model, [ "ui", "isBreadcrumbDropdownOpen" ], false);
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

const filterHidden = (model, specializations) => {
  if (model.app.currentUser.role === "user"){
    return specializations.filter((specialization) => {
      return !hiddenFromUsers(specialization, model)
    })
  }
  else {
    return specializations;
  }
}

const BreadcrumbDropdownColumn = ({model, dispatch, columnNumber}) => {
  const specializations = _.values(model.app.specializations)
    .pwPipe((specializations) => _.sortBy(specializations, "name") )
    .pwPipe(_.partial(filterHidden, model))
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
                className={hiddenClass(model, specialization)}
                onClick={_.partial(toggleBreadcrumbDropdown, dispatch, false)}
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
    return <span className="new" style={{marginLeft: "3px"}}>NEW</span>
  } else {
    return <span/>
  }
}

const hiddenClass = (model, specialization) => {
  if (hiddenFromUsers(specialization, model)) {
    return "hidden-from-users";
  }
  else {
    return "";
  }
}

const ParentSpecialtyBreadcrumb = ({model}) => {
  if (route === "/areas_of_practice/:id"){
    const names = recordShownByRoute(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (recordShownByRoute(model).specializationIds.length > 2) {
      var label = `${names.join(", ")}...`;
    }
    else {
      var label = names.join(", ");
    }


    return(
      <li className="subsequent specialty">
        <span style={{marginLeft: "4px"}}>{ label }</span>
      </li>
    );
  }
  else {
    return <span></span>;
  }
};

const ParentProcedureBreadcrumb = ({model, level}) => {
  if (route === "/areas_of_practice/:id"){
    const names = recordShownByRoute(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (level === -1) {
      var className = "parent";
    }
    else {
      var className = "grandparent";
    }

    const procedureIdIndex = recordShownByRoute(model).ancestorIds.length + level;
    const procedureId = recordShownByRoute(model).ancestorIds[procedureIdIndex];

    if (procedureId) {
      return(
        <li className={`subsequent ${className}`}>
          <span style={{marginLeft: "4px"}}>
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

const ChildBreadcrumb = ({model}) => {
  if (route === "/specialties/:id"){
    return(
      <ChildBreadcrumbWrapper model={model}>
        <span style={{marginLeft: "4px"}}>{ recordShownByBreadcrumb(model).name }</span>
        <NewTag model={model} specialization={recordShownByBreadcrumb(model)}/>
      </ChildBreadcrumbWrapper>
    );
  }
  else if (route === "/areas_of_practice/:id"){
    return(
      <ChildBreadcrumbWrapper model={model}>
        <span style={{marginLeft: "4px"}}>{ recordShownByBreadcrumb(model).name }</span>
      </ChildBreadcrumbWrapper>
    );
  }
  else if (_.includes(
    [ "/clinics/:id", "/specialists/:id", "/content_items/:id" ],
    route
  ) && recordShownByBreadcrumb(model)){
    return(
      <ChildBreadcrumbWrapper model={model}>
        <span style={{marginLeft: "4px"}}>{ recordShownByBreadcrumb(model).name }</span>
        <NewTag model={model} specialization={recordShownByBreadcrumb(model)}/>
      </ChildBreadcrumbWrapper>
    );
  }
  else {
    return <span></span>;
  }
};

const ChildBreadcrumbWrapper = ({model, children}) => {
  return(
    <li className={childClassName(model)}>
      <a href={window.location.pathname} style={{color: "#666666"}}>
        { children }
      </a>
    </li>
  )
}

const childClassName = (model) => {
  let classes = ["subsequent child"];

  if (route !== "/areas_of_practice/:id"){
    if (route === "/specialties/:id"){
      var specialization = recordShownByRoute(model);
    }
    else {
      var specialization =
        model.app.specializations[model.ui.dropdownSpecializationId];
    }

    classes.push(hiddenClass(model, specialization));
  }

  if (dropdownIsOpen(model)){
    classes.push("is-open");
  }

  return classes.join(" ");
}

export default Breadcrumbs;
