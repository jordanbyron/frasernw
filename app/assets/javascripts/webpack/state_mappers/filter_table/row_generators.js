var React = require("react");
var FavoriteIcon = require("../../react_components/icons/favorite");
var FeedbackIcon = require("../../react_components/icons/feedback");
var SharedCareIcon = require("../../react_components/icons/shared_care");
var ReferentStatusIcon = require("../../react_components/icons/referent_status_icon");
var Tags = require("../../react_components/tags");
var reject = require("lodash/collection/reject");
var trackContentItem = require("../../analytics_wrappers").trackContentItem;
var _ = require("lodash");


const pediatricsId = (app) => {
  return _.find(
    app.specializations,
    (specialization) => specialization.name === "Pediatrics"
  ).id;
}

const isPediatrician = (record, app) => {
  return _.includes(record.specializationIds, parseInt(pediatricsId(app)));
}

const showPedSuffix = (record, app, specializationId) => {
  return record.seesOnlyChildren &&
    record.specializationIds.length > 1 &&
    isPediatrician(record, app) &&
    specializationId !== parseInt(pediatricsId(app));
}

const suffix = (record, app, specializationId) => {
  if (record.collectionName === "clinics") {
    return "";
  }
  else if (record.isGP) {
    return "GP";
  }
  else if (record.isInternalMedicine) {
    return "Int Med";
  }
  else if (showPedSuffix(record, app, specializationId)) {
    return "Ped";
  }
  else {
    return _.find(
      record.specializationIds.map((id) => app.specializations[id].suffix),
      (suffix) => suffix && suffix.length > 0
    );
  }
};

const Suffix = ({record, app, specializationId}) => {
  return(
    <span style={{marginLeft: "5px"}} className="suffix" key="suffix">
      {suffix(record, app, specializationId)}
    </span>
  )
}

// name of specialist / clinic
// E.g. John Smith || St. Paul's Clinic
var labelReferentName = function(record, app, specializationId) {
  return (
    <span>
      <a href={"/" + record.collectionName + "/" + record.id}>{ record.name }</a>
      <Suffix record={record} app={app} specializationId={specializationId}/>
      <Tags record={record}/>
    </span>
  );
}

// status icon
// e.g. 'Accepting Referrals' checkmark
var labelReferentStatus = function(record, statusIcons, tooltips) {
  return (
    <ReferentStatusIcon record={record} statusIcons={statusIcons} tooltips={tooltips}/>
  );
}

// cities row
// e.g. "Vancouver"
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
      <a
        href={record.resolvedUrl}
        target="_blank"
        onClick={function() { trackContentItem(_gaq, record.id) }}
      >{ record.title }</a>
      <Tags record={record}/>
    </span>
  );
}

var email = function(record) {
  if (record.canEmail){
    return(<i
      onClick={function(){ window.location.href=("/content_items/" + record.id + "/email")}}
      className="icon-envelope-alt icon-blue"
      title="Email this item"
    />);
  } else {
    return null;
  }
}

var labelWaittime = function(record, custom, procedureId, waittimeHash) {
  if(custom){
    return (waittimeHash[record.customWaittimes[procedureId]] || "");
  } else {
    return (record.waittime || "");
  }
};

module.exports = {
  referents: function(app, dispatch, config, record) {
    return {
      cells: reject([
        labelReferentName(record, app, config.specializationId),
        labelReferentSpecialties(record, app, config.includingOtherSpecialties),
        labelReferentStatus(record, app.referentStatusIcons, app.tooltips),
        labelWaittime(record, config.customWaittime.shouldUse, config.customWaittime.procedureId, app.waittimeHash),
        labelReferentCities(record, app)
      ], (cell) => cell === null),
      reactKey: (record.collectionName + record.id),
      record: record
    }
  },
  resources: function(app, dispatch, config, record) {
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
