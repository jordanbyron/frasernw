import _ from "lodash";
import app from "reducers/app";
import ui from "reducers/ui";

// app - what is true 'objectively' about Pathways
// ui - what is true about this view in particular

const topLevel = (state = {}, action) => {
  switch(action.type){
  default:
    return {
      app: app(state.app, action),
      ui: ui(state.ui, action)
    };
  }
};

export default topLevel;
