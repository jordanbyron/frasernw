import React from "react";
import { buttonIsh} from "stylesets";

const EditIssue = ({model, issue}) => {
  if (model.app.currentUser.role === "super") {
    return(
      <a href={`/issues/${issue.id}/edit`}
        style={{marginLeft: "10px"}}
        className="issue_row__edit"
      >
        <i
          className="icon-pencil icon-disabled"
          style={buttonIsh}
          title="Edit Issue"
        />
      </a>
    );
  } else {
    return(
      <noscript/>
    );
  }
}

export default EditIssue;
