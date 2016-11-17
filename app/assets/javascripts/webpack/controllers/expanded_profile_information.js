import React from "react";
import { areRowsExpanded } from "controller_helpers/table_row_expansion";
import ExpandingContainer from "component_helpers/expanding_container";

const ExpandedProfileInformation = React.createClass({
  render: function(){
    return(
      <ExpandingContainer expanded={areRowsExpanded(this.props.model)}>
        <InnerContent model={this.props.model} record={this.props.record}/>
      </ExpandingContainer>
    );
  }
});

const InnerContent = ({model, record}) => {
  if ((record.collectionName === "specialists" && record.isPracticing)||
    record.collectionName === "clinics" && record.isOpen){

    return(
      <ul>
        <NotPerformed record={record}/>
        <MostInterested record={record}/>
      </ul>
    );
  }
  else {
    return <noscript/>;
  }
}

const MostInterested = ({record}) => {
  if (record.interest){
    return(<MiniProfileItem heading={"Most interested in:"} value={record.interest}/>);
  }
  else {
    return(<noscript/>);
  }
}

const NotPerformed = ({record}) => {
  if (record.notPerformed){
    return(<MiniProfileItem heading={"Does not see or do:"} value={record.notPerformed}/>);
  }
  else {
    return(<noscript/>);
  }
}

const MiniProfileItem = ({heading, value}) => {
  return(
    <li>
      <div className="mini-profile__item">
        <i>{`${heading} `}</i>
        <span dangerouslySetInnerHTML={{__html: value}}></span>
      </div>
    </li>
  )
}

export default ExpandedProfileInformation;
