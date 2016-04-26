var React = require("react");
var FavoriteIcon = require("../../react_components/icons/favorite");
var FeedbackIcon = require("../../react_components/icons/feedback");
var SharedCareIcon = require("../../react_components/icons/shared_care");
var ReferentStatusIcon = require("../../react_components/icons/referent_status_icon");
var Tags = require("../../react_components/tags");
var reject = require("lodash/collection/reject");
var trackContentItem = require("../../analytics_wrappers").trackContentItem;
var _ = require("lodash");


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
      <i>{`${heading} `}</i>
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
      <MostInterested record={record}/>
      <NotPerformed record={record}/>
    </div>
  )
}

var labelReferentName = function(record, app, config) {
  return (
    <div>
      <a
        className="datatable__referent_name"
        href={"/" + record.collectionName + "/" + record.id}
        style={{position: "relative"}}
        onClick={function(e){ e.stopPropagation() }}
      >
        { record.name }
      </a>
      <span  style={{marginLeft: "5px"}} className="suffix" key="suffix">{record.suffix}</span>
      <Tags record={record}/>
      <ExpandedInformation record={record} config={config}/>
    </div>
  );
}

const ExpandedInformation = React.createClass({
  isSelected: function() {
    return this.props.config.selectedRecordId === this.props.record.id;
  },
  componentDidMount: function(){
    if (this.isSelected()){
      $(this.refs.content).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.isSelected();
    var selectedInPrevProps = prevProps.config.selectedRecordId === this.props.record.id;

    if (selectedInPrevProps == false && selectedInCurrentProps == true) {
      $(this.refs.content).slideDown("fast");
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.content).slideUp("fast");
    }
  },
  render: function(){
    if (this.props.record.interest && this.props.record.notPerformed){
      return(
        <ul ref="content" style={{display: "none"}}>
          <li><MostInterested record={this.props.record}/></li>
          <li><NotPerformed record={this.props.record}/></li>
        </ul>
      );
    } else {
      return(
        <div style={{marginTop: "5px", display: "none"}} ref="content">
          <i>
            {
              `This ${this.props.record.collectionName.slice(0, -1)} hasn't provided us information about their ` +
              "interests or restrictions."
            }
          </i>
        </div>
      );
    }
  }
})

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

const onReferentClick = (record, selectedRecordId, panelKey, dispatch) => {
  dispatch({
    type: "TOGGLE_SELECTED_RECORD",
    record: record,
    selectedRecordId: selectedRecordId,
    panelKey: panelKey,
    reducer: "FilterTable"
  })
}

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
      record: record,
      onClick: _.partial(onReferentClick, record, config.selectedRecordId, config.panelKey, dispatch),
      isSelected: (config.selectedRecordId === record.id)
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
