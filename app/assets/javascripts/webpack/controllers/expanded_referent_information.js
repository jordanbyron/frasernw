import React from "react";
import { areRowsExpanded } from "controller_helpers/table_row_expansion";
import ExpandingContainer from "component_helpers/expanding_container";

const ExpandedReferentInformation = React.createClass({
  render: function(){
    return(
      <ExpandingContainer expanded={areRowsExpanded(this.props.model)}>
        <ul ref="content">
          <NotPerformed record={this.props.record}/>
          <MostInterested record={this.props.record}/>
        </ul>
      </ExpandingContainer>
    );
  }
});

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
        <span>{value}</span>
      </div>
    </li>
  )
}

export default ExpandedReferentInformation;
