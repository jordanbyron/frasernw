var _ = require("lodash");

module.exports = function(stateProps, dispatchProps) {
  var state = stateProps;
  var dispatch = dispatchProps.dispatch;

  console.log(state);

  if (state.ui.hasBeenInitialized) {
    return {
      title: "Pathways Specialists",
      lists: lists(state),
      isLoading: false,
      dispatch: dispatch
    };
  } else {
    return {
      isLoading: true
    };
  }
};

var lists = function(state) {
  return _.values(state.app.specializations).map((specialization) => {
    return {
      title: specialization.name,
      items: specializationReferents(_.values(state.app.specialists), specialization.id),
      key: specialization.id
    };
  });
};

var specializationReferents = function(referents, specializationId) {
  return referents.filter((referent) => {
    return _.includes(referent.specializationIds, specializationId);
  }).map((referent) => referent.name);
};
