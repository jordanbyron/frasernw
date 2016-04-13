var React = require("react");
var FavoriteIcon = require("../../react_components/icons/favorite");
var FeedbackIcon = require("../../react_components/icons/feedback");
var SharedCareIcon = require("../../react_components/icons/shared_care");
var ReferentStatusIcon = require("../../react_components/icons/referent_status_icon");
var Tags = require("../../react_components/tags");
var reject = require("lodash/collection/reject");
var trackContentItem = require("../../analytics_wrappers").trackContentItem;


const MostInterested = ({record}) => {
  if (record.interest){
    return(<MiniProfileItem heading={"Most interested in:"} value={record.interest}/>);
  }
  else {
    return(<span></span>);
  }
}

const NotPerformed = ({record}) => {
  if (record.notPerformed){
    return(<MiniProfileItem heading={"Does not see or do:"} value={record.notPerformed}/>);
  }
  else {
    return(<span></span>);
  }
}

const MSP = ({record}) => {
  if (record.collectionName === "specialists" && record.billingNumber) {
    return(<MiniProfileItem heading="Billing Number:" value={record.billingNumber}/>)
  }
  else {
    return(<span></span>);
  }
}

const MiniProfileItem = ({heading, value}) => {
  return(
    <div className="mini-profile__item">
      <b>{`${heading} `}</b>
      <span>{value}</span>
    </div>
  )
}

const SpecializesIn = ({record, app}) => {
  return(
    <MiniProfileItem
      heading={"Specializes In:"}
      value={record.specializationIds.map((id) => app.specializations[id].name ).join(", ")}
    />
  );
}

const MiniProfile = ({record, app, config}) => {
  const tooltipKey = {
    specialists: "statusClassKey",
    clinics: "statusMask",
  }[record.collectionName];


  return(
    <div className="mini-profile">
      <h3 className="mini-profile__title">{record.name}</h3>
      <p style={{color: "#040404", marginLeft: "0px", marginTop: "5px"}}>
        <span style={{marginRight: "5px"}}>
          { labelReferentStatus(record, app.referentStatusIcons, app.tooltips) }
        </span>
        <span>{ app.tooltips[record.collectionName][record[tooltipKey]] }</span>
      </p>
      <div className="headline-footer" style={{marginTop: "7px"}}/>
      <MostInterested record={record}/>
      <NotPerformed record={record}/>
      <MSP record={record}/>
      <MiniProfileItem
        heading="Average Non-urgent Patient Waittime:"
        value={labelWaittime(record, config.customWaittime.shouldUse, config.customWaittime.procedureId, app.waittimeHash)}
      />
      <MiniProfileItem
        heading="Practices in:"
        value={labelReferentCities(record, app)}
      />
      <SpecializesIn record={record} app={app}/>
    </div>
  )
}

var labelReferentName = function(record, app, config) {
  return (
    <span>
      <a
        className="datatable__referent_name"
        href={"/" + record.collectionName + "/" + record.id}
        style={{position: "relative"}}
      >
        <span>{ record.name }</span>
        <MiniProfile record={record} app={app} config={config} onClick={function(e) { return false; }}/>
      </a>
      <span  style={{marginLeft: "5px"}} className="suffix" key="suffix">{record.suffix}</span>
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
        labelReferentName(record, app, config),
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
