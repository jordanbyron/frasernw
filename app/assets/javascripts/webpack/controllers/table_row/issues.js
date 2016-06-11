import React from "react";
import _ from "lodash"
import EditIssue from "controllers/icons/edit_issue";

const IssueRow = ({model, decoratedRecord}) => {
  return(
    <tr>
      <td>{ decoratedRecord.raw.id }</td>
      <td>
        <a href={`/issues/${decoratedRecord.raw.id}`}>
          { label(decoratedRecord) }
        </a>
        <EditIssue issue={decoratedRecord.raw} model={model}/>
      </td>
      <td>{ sourceLabel(decoratedRecord, model) }</td>
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
