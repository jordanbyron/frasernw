import React from 'react';
import _ from 'lodash';
import { toSentence } from 'utils';


const LatestUpdates = ({state, dispatch}) => {
  console.log(state);

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
        <h2>{`Specialist and Clinic Updates for ${toSentence(divisionNames)}`}</h2>
        <ShowHiddenToggle dispatch={dispatch} canHide={state.ui.canHide} showHiddenUpdates={showHiddenUpdates}/>
        <br/>
        {
          updatesToShow.map((update) => (
            <LatestUpdate key={updateKey(update)}
              dispatch={dispatch}
              update={update}
              canHide={state.ui.canHide}
            />
          ))
        }
      </div>
    );
  } else {
    return(<div></div>);
  }
}

const ShowHiddenToggle = ({dispatch, showHiddenUpdates, canHide}) => {
  const text = function() {
    if(showHiddenUpdates){
      return "Do not show hidden updates";
    } else {
      return "Show hidden updates";
    }
  }();

  if(canHide) {
    return(<a onClick={_.partial(toggleHiddenUpdateVisibility, dispatch, !showHiddenUpdates)}>{text}</a>);
  }
  else {
    return <div></div>;
  }
}

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
  return (
    <div className="latest_updates__update">
      <HideToggle update={update} canHide={canHide} dispatch={dispatch}/>
      <span dangerouslySetInnerHTML={{__html: update.markup}}/>
      <HiddenBadge isHidden={update.hidden}/>
    </div>
  );
};

const HiddenBadge = ({isHidden}) => {
  if(isHidden){
    return <span>{" (Hidden)"}</span>;
  }
  else {
    return <span></span>;
  }
}

const toggleUpdateVisibility = (dispatch, update) => {
  const updateIdentifiers = _.omit(update, "markup", "hidden");
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
    type: "PUT",
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
  }()

  if (canHide) {
    return(
      <a onClick={_.partial(toggleUpdateVisibility, dispatch, update)}
        className="latest_updates__toggle"
      >
        <i className="icon-remove"/>
        <span>{text}</span>
      </a>

    )
  }
  else {
    return(<div></div>);
  }
}

module.exports = LatestUpdates;
