import React from "react";
import ReactDOM from "react-dom";
import { recordShownByPage, matchedRoute } from "controller_helpers/routing";
import hiddenFromUsers from "controller_helpers/hidden_from_users";
import _ from "lodash";

const ROUTES_SHOWING = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/clinics/:id",
  "/specialists/:id",
  "/faq_categories/:id",
  "/referral_forms/:id",
  "/content_items/:id",
  "/terms_and_conditions",
  "/"
];

const Breadcrumbs = React.createClass({
  getInitialState: function(){
    return { dropdownIsOpen: false };
  },
  componentDidMount: function() {
    $("body").click((e) => {
      var domNode = ReactDOM.findDOMNode(this);
      if(!domNode || !domNode.contains(e.target)){
        this.setState({dropdownIsOpen: false})
      }
    })
  },
  toggle: function() {
    this.setState({dropdownIsOpen: !this.state.dropdownIsOpen});
  },
  render: function() {
    if (_.includes(ROUTES_SHOWING, matchedRoute(this.props.model))){

      return(
        <div>
          <ul id="specialties-menu">
            <li className={dropdownClassName(this.props.model)}>
              <a className="specialties-dropdown-toggle" onClick={this.toggle}>
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
            isOpen={this.state.dropdownIsOpen}
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
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))){
    return "dropdown";
  }
  else {
    return "dropdown no-caret";
  }
}

const dropdownIsOpen = (model) => {
  return _.get(model, [ "ui", "isBreadcrumbDropdownOpen" ], false);
}

const BreadcrumbDropdown = ({model, dispatch, isOpen}) => {
  if(isOpen) {
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
    return <span className="new">NEW</span>
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
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    const names = recordShownByPage(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (recordShownByPage(model).specializationIds.length > 2) {
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
  if (matchedRoute(model) === "/areas_of_practice/:id"){
    const names = recordShownByPage(model).
      specializationIds.map((id) => model.app.specializations[id].name).
      slice(0, 2);

    if (level === -1) {
      var className = "parent";
    }
    else {
      var className = "grandparent";
    }

    const procedureIdIndex = recordShownByPage(model).ancestorIds.length + level;
    const procedureId = recordShownByPage(model).ancestorIds[procedureIdIndex];

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
  if (matchedRoute(model) === "/specialties/:id"){
    return(
      <li className={`subsequent ${hiddenClass(model, recordShownByPage(model))}`}>
        <span style={{marginLeft: "4px"}}>{ recordShownByPage(model).name }</span>
        <NewTag model={model} specialization={recordShownByPage(model)}/>
      </li>
    );
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    return(
      <li className="subsequent">
        <span style={{marginLeft: "4px"}}>{ recordShownByPage(model).name }</span>
      </li>
    );
  }
  else if (_.includes(
    [ "/clinics/:id", "/specialists/:id", "/content_items/:id" ],
    matchedRoute(model)
  ) && model.ui.dropdownSpecializationId){
    
    let specialization = model.app.specializations[model.ui.dropdownSpecializationId]

    return(
      <li className={`subsequent ${hiddenClass(model, specialization)}`}>
        <span style={{marginLeft: "4px"}}>{ specialization.name }</span>
        <NewTag model={model} specialization={specialization}/>
      </li>
    );
  }
  else {
    return <span></span>;
  }
};

export default Breadcrumbs;
