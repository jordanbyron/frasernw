import React from "react";
import _ from "lodash"
import { selectedTabKey } from "controller_helpers/tab_keys";

const ChangeRequestRow = ({model, decoratedRecord}) => {
  if (selectedTabKey(model) === "pendingIssues"){
    return(
      <tr>
        <td>{ decoratedRecord.raw.id }</td>
        <td><Link decoratedRecord={decoratedRecord}/></td>
        <td>{ decoratedRecord.raw.dateEntered }</td>
        <td>{ decoratedRecord.raw.priority }</td>
        <td>{ decoratedRecord.raw.effort }</td>
        <td>
          { model.app.progressLabels[decoratedRecord.raw.progressKey] }
        </td>
        <td>
          {
            model.
              app.
              completionEstimateLabels[decoratedRecord.raw.completionEstimateKey]
          }
        </td>
      </tr>
    );
  }
  else {
    return(
      <tr>
        <td>{ decoratedRecord.raw.id }</td>
        <td><Link decoratedRecord={decoratedRecord}/></td>
        <td>{ decoratedRecord.raw.dateEntered }</td>
        <td>{ decoratedRecord.raw.dateCompleted }</td>
        <td>{ decoratedRecord.raw.effort }</td>
      </tr>
    );
  }
}

const Link = ({decoratedRecord}) => {
  return(
    <a href={`/issues/${decoratedRecord.raw.id}`}>{label(decoratedRecord)}</a>
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
