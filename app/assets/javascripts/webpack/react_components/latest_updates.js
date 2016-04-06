import React from 'react';
import _ from 'lodash';
import { toSentence } from 'utils';
import { buttonIsh } from 'stylesets';
import SidebarLayout from 'react_components/sidebar_layout';
import SidebarWell from 'react_components/sidebar_well';
import SidebarWellSection from 'react_components/sidebar_well_section';
import Checkbox from 'react_components/checkbox';


const LatestUpdates = ({state, dispatch}) => {
  if(state.ui.hasBeenInitialized) {
    const divisionNames = state.ui.divisionIds.map((id) => state.app.divisions[id].name);
    const showHiddenUpdates = _.get(state, ["ui", "showHiddenUpdates"], false);
    const updatesToShow = function() {
      if(showHiddenUpdates) {
        return state.ui.latestUpdates;
      } else {
        return state.ui.latestUpdates.filter((update) => !update.hidden);
      }
    }()

    return(
      <div className="content-wrapper">
        <h2 style={{marginBottom: "10px"}}>{`Latest Specialist and Clinic Updates for ${toSentence(divisionNames)}`}</h2>
        <PageBody showHiddenUpdates={showHiddenUpdates} updatesToShow={updatesToShow} dispatch={dispatch} canHide={state.ui.canHide}/>
      </div>
    );
  } else {
    return(<div></div>);
  }
}

const Updates = ({updatesToShow, canHide, dispatch}) => {
  return(
    <div>
      {
        updatesToShow.map((update) => (
          <LatestUpdate key={updateKey(update)}
            dispatch={dispatch}
            update={update}
            canHide={canHide}
          />
        ))
      }
    </div>
  );
};

const PageBody = ({showHiddenUpdates, updatesToShow, dispatch, canHide}) => {
  if(canHide) {
    return(
      <SidebarLayout
        main={
          <Updates dispatch={dispatch} updatesToShow={updatesToShow} canHide={true}/>
        }
        sidebar={
          <SidebarWell title="Admin-Only Options">
            <SidebarWellSection title="Hidden Updates">
              <div style={{marginTop: "10px"}}>
                <Checkbox label="Show updates that are hidden from users"
                  onChange={_.partial(toggleHiddenUpdateVisibility, dispatch, !showHiddenUpdates)}
                  value={showHiddenUpdates}
                />
              </div>
            </SidebarWellSection>
          </SidebarWell>
        }
        reducedView={"main"}
      />
    );
  }
  else {
    return(<Updates dispatch={dispatch} updatesToShow={updatesToShow} canHide={false}/>);
  }
};

const toggleHiddenUpdateVisibility = (dispatch, newValue) => {
  dispatch(
    {
      type: "TOGGLE_HIDDEN_UPDATE_VISIBILITY",
      newValue: newValue
    }
  );
};

const updateKey = (update) => {
  return _.values(_.omit(update, "markup")).join(".");
};

const LatestUpdate = ({dispatch, update, canHide}) => {
  const classNameSpecifier = canHide ? "latest_updates__update--editable" : "";

  return (
    <div className={`latest_updates__update ${classNameSpecifier}`}>
      <div className="latest_updates__update_text">
        <span dangerouslySetInnerHTML={{__html: update.markup}}/>
        <HiddenBadge isHidden={update.hidden}/>
      </div>
      <HideToggle update={update} canHide={canHide} dispatch={dispatch}/>
    </div>
  );
};

const HiddenBadge = ({isHidden}) => {
  if(isHidden){
    return <span className="label label-default" style={{marginLeft: "10px"}}>{"Hidden"}</span>;
  }
  else {
    return <span></span>;
  }
}

const toggleUpdateVisibility = (dispatch, update) => {
  const updateIdentifiers = _.omit(update, "markup", "hidden", "manual");
  const params = _.assign(
    {},
    updateIdentifiers,
    { hide: !update.hidden }
  );

  dispatch({
    type: "TOGGLE_UPDATE_VISIBILITY",
    update: updateIdentifiers,
    hide: !update.hidden
  });

  $.ajax({
    url: `/latest_updates/toggle_visibility`,
    type: "PATCH",
    data: {update: params }
  })
};

const HideToggle = ({update, canHide, dispatch}) => {
  const text = function() {
    if (update.hidden){
      return "Show";
    }
    else {
      return "Hide";
    }
  }();

  const icon = function() {
    if (update.hidden) {
      return "icon-check";
    }
    else {
      return "icon-remove";
    }
  }();

  if (canHide && !update.manual) {
    return(
      <a onClick={_.partial(toggleUpdateVisibility, dispatch, update)}
        style={buttonIsh}
        className="latest_updates__toggle"
      >
        <i className={icon} style={{marginRight: "5px"}}/>
        <span>{text}</span>
      </a>

    )
  }
  else {
    return(<div></div>);
  }
}

module.exports = LatestUpdates;
