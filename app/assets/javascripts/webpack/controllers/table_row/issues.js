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
          { label(decoratedRecord) }
        </a>
        <EditIssue issue={decoratedRecord.raw} model={model}/>
      </td>
    </tr>
  );
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
