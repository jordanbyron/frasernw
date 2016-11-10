import React from "react";
import _ from "lodash"
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import EditIssue from "controllers/icons/edit_issue";
import { link } from "controller_helpers/links";


const ChangeRequestRow = ({model, decoratedRecord}) => {
  if (selectedTabKey(model) === "pendingIssues"){
    if(model.ui.persistentConfig.showIssueEstimates){
      return(
        <tr>
          <td>{ decoratedRecord.raw.sourceId }</td>
          <td>
            <Link decoratedRecord={decoratedRecord}/>
            <EditIssue issue={decoratedRecord.raw} model={model}/>
          </td>
          <td>{ decoratedRecord.raw.dateEntered }</td>
          <td>{ decoratedRecord.raw.priority }</td>
          <td>{ decoratedRecord.raw.effortEstimate }</td>
          <td>
            { model.app.progressLabels[decoratedRecord.raw.progressKey] }
          </td>
          <td>
            { completionEstimate(decoratedRecord.raw) }
          </td>
        </tr>
      );
    }
    else {
      return(
        <tr>
          <td>{ decoratedRecord.raw.sourceId }</td>
          <td>
            <Link decoratedRecord={decoratedRecord}/>
            <EditIssue issue={decoratedRecord.raw} model={model}/>
          </td>
          <td>{ decoratedRecord.raw.dateEntered }</td>
          <td>{ decoratedRecord.raw.priority }</td>
          <td>{ decoratedRecord.raw.effortEstimate }</td>
          <td>
            { model.app.progressLabels[decoratedRecord.raw.progressKey] }
          </td>
        </tr>
      );
    }
  }
  else {
    return(
      <tr>
        <td>{ decoratedRecord.raw.sourceId }</td>
        <td><Link decoratedRecord={decoratedRecord}/></td>
        <td>{ decoratedRecord.raw.dateEntered }</td>
        <td>{ decoratedRecord.raw.dateCompleted }</td>
        <td>{ decoratedRecord.raw.effort }</td>
      </tr>
    );
  }
}

const completionEstimate = (record) => {
  if(record.completeThisWeekend){
    return "<= This Weekend";
  }
  else if (record.completeNextMeeting){
    return "<= Next U.G. Meeting";
  }
  else {
    return "> Next U.G. Meeting";
  }
}

const Link = ({decoratedRecord}) => {
  return(
    <a href={link(decoratedRecord.raw)}>{label(decoratedRecord)}</a>
  );
}

const label = (decoratedRecord) => {
  if (decoratedRecord.raw.title) {
    return decoratedRecord.raw.title;
  }
  else {
    return decoratedRecord.raw.description;
  }
}

export default ChangeRequestRow;
