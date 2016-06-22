import React from "react";
import { areRowsExpanded } from "controller_helpers/table_row_expansion";

const ExpandedReferentInformation = React.createClass({
  render: function(){
    if (areRowsExpanded(this.props.model)){
      return(
        <ul ref="content">
          <NotPerformed record={this.props.record}/>
          <MostInterested record={this.props.record}/>
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
