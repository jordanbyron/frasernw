import React from "react";
import _ from "lodash"
import EditIssue from "controllers/icons/edit_issue";
import { link } from "controller_helpers/links";

const IssueRow = ({model, decoratedRecord}) => {
  return(
    <tr>
      <td>{ decoratedRecord.raw.code }</td>
      <td>
        <a href={link(decoratedRecord.raw)}>
          <span>{ label(decoratedRecord) }</span>
          <ReadyToTestIcon decoratedRecord={decoratedRecord}/>
        </a>
        <EditIssue issue={decoratedRecord.raw} model={model}/>
      </td>
    </tr>
  );
}

const ReadyToTestIcon = ({decoratedRecord}) => {
  if(decoratedRecord.raw.progressKey === 6){
    return <i className="icon icon-thumbs-up" style={{marginLeft: "5px"}}></i>;
  }
  else {
    return <noscript/>;
  }
}

const sourceLabel = (decoratedRecord, model) => {
  if(decoratedRecord.raw.sourceId){
    return(model.app.issueSources[decoratedRecord.raw.sourceKey] +
      decoratedRecord.raw.sourceId);
  }
  else {
    return model.app.issueSources[decoratedRecord.raw.sourceKey];
  }
}

const label = (decoratedRecord) => {
  if (decoratedRecord.raw.title) {
    return decoratedRecord.raw.title;
  }
  else {
    return decoratedRecord.raw.description;
  }
}

export default IssueRow;
