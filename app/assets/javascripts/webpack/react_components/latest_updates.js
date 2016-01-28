import React from 'react';
import _ from 'lodash';
import { toSentence } from 'utils';


const LatestUpdates = ({state, dispatch}) => {
  console.log(state);

  if(state.ui.hasBeenInitialized) {
    const divisionNames = state.ui.divisionIds.map((id) => state.app.divisions[id].name);
    return(
      <div className="content-wrapper">
        <h2>{`Specialist and Clinic Updates for ${toSentence(divisionNames)}`}</h2>
        <br/>
        {
          state.ui.latestUpdates.map((update) => (
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

const updateKey = (update) => {
  return _.values(_.omit(update, "markup")).join(".");
};

const LatestUpdate = ({dispatch, update, canHide}) => {
  return (
    <div className="latest_updates__update">
      <HideToggle update={update} canHide={canHide} dispatch={dispatch}/>
      <span dangerouslySetInnerHTML={{__html: update.markup}}/>
    </div>
  );
};

const toggleUpdateVisibility = (dispatch, update) => {
  const updateIdentifiers = _.omit(update, "markup");

  dispatch({
    type: "TOGGLE_UPDATE_VISIBILITY",
    update: updateIdentifiers
  });

  $.ajax({
    url: `/latest_updates_masks/?${$.param(updateIdentifiers)}`,
    type: "POST"
  })
}

const HideToggle = ({update, canHide, dispatch}) => {
  if (canHide) {
    return(
      <a onClick={_.partial(toggleUpdateVisibility, dispatch, update)}
        className="latest_updates__toggle"
      >
        <i className="icon-remove"/>
        <span>{"Hide"}</span>
      </a>

    )
  }
  else {
    return(<div></div>);
  }
}

module.exports = LatestUpdates;
