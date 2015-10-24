var React = require("react");
var FavoriteIcon = require("../../react_components/icons/favorite");
var FeedbackIcon = require("../../react_components/icons/feedback");
var SharedCareIcon = require("../../react_components/icons/shared_care");
var Tags = require("../../react_components/tags");
var reject = require("lodash/collection/reject");

var labelReferentName = function(record) {
  return (
    <span>
      <a href={"/" + record.collectionName + "/" + record.id}>{ record.name }</a>
      <Tags record={record}/>
    </span>
  );
}

var labelReferentStatus = function(record) {
  return (
    <i className={record.statusIconClasses}></i>
  );
}

var labelReferentCities = function(record, app) {
  if (record.cityIds.length > 0) {
    return record
      .cityIds
      .map((id) => app.cities[id].name)
      .join(" and ");
  } else {
    return "";
  }
}

var labelReferentSpecialties = function(record, app, includeSpecializations) {
  if (includeSpecializations) {
    return(
      record
        .specializationIds
        .map((id) => app.specializations[id].name)
        .join(" and ")
    );
  } else {
    return null;
  }
}

var openFeedbackModal = function(resource) {
  return {
    type: "OPEN_FEEDBACK_MODAL",
    data: {
      id: resource.id,
      type: "ScItem",
      title: resource.title
    }
  };
}

var dispatchOpenFeedbackModal = function(resource, dispatch) {
  dispatch(
    openFeedbackModal(resource)
  );
}

var labelResourceTitle = function(record) {
  return(
    <span>
      <SharedCareIcon color="blue" shouldDisplay={record.isSharedCare}/>
      <a href={record.resolvedUrl}>{ record.title }</a>
      <Tags record={record}/>
    </span>
  );
}

var email = function(record) {
  if (record.canEmail){
    return(<i
      onClick={function(){ window.location.href=("/content_items/" + record.id + "/email")}}
      className="icon-envelope-alt icon-blue"
    />);
  } else {
    return null;
  }
}

module.exports = {
  referents: function(record, app, dispatch, config) {
    return {
      cells: reject([
        labelReferentName(record),
        labelReferentSpecialties(record, app, config.includingOtherSpecialties),
        labelReferentStatus(record),
        (record.waittime || ""),
        labelReferentCities(record, app)
      ], (cell) => cell === null),
      reactKey: (record.collectionName + record.id),
      record: record
    }
  },
  resources: function(record, app, dispatch, config) {
    return {
      cells: [
        labelResourceTitle(record),
        app.contentCategories[record.categoryId].name,
        <FavoriteIcon
          record={record}
          favorites={app.currentUser.favorites}
          dispatch={dispatch}
          collection="contentItems"
          collectionPath="content_items"
        />,
        email(record),
        <FeedbackIcon record={record} itemType="ScItem" dispatch={dispatch}/>
      ],
      reactKey: (config.panelKey + record.id),
      record: record
    }
  }
}
