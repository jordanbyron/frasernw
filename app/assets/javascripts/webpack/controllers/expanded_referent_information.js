import React from "react";
import selectedRecordId from "controller_helpers/selected_record_id";

const ExpandedReferentInformation = React.createClass({
  isSelected: function() {
    return selectedRecordId(this.props.model) === this.props.record.id;
  },
  componentDidMount: function(){
    if (this.isSelected()){
      $(this.refs.content).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.isSelected();
    var selectedInPrevProps = selectedRecordId(prevProps.model) === this.props.record.id;

    if (selectedInPrevProps == false && selectedInCurrentProps == true) {
      $(this.refs.content).slideDown("medium");
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.content).slideUp("medium");
    }
  },
  render: function(){
    if (this.props.record.collectionName == "specialists") {
      var noInfoLabel =
        "This specialist hasn't provided us information about their interests or restrictions.";
    } else {
      var noInfoLabel =
        "This clinic hasn't provided us information about their restrictions.";
    }

    if (this.props.record.interest || this.props.record.notPerformed){
      return(
        <ul ref="content" style={{display: "none"}}>
          <MostInterested record={this.props.record}/>
          <NotPerformed record={this.props.record}/>
        </ul>
      );
    } else {
      return(
        <noscript/>
      );
    }
  }
});

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

const MiniProfileItem = ({heading, value}) => {
  return(
    <li>
      <div className="mini-profile__item">
        <i>{`${heading} `}</i>
        <span>{value}</span>
      </div>
    </li>
  )
}

export default ExpandedReferentInformation;
