import React from "react";

const EmailIcon = ({record}) => {
  if (record.canEmail){
    return(
      <a href={`/content_items/${record.id}/email`}>
        <i
          className="icon-envelope-alt icon-blue"
          title="Email this item"
        />
      </a>
    );
  } else {
    return <noscript/>;
  }
}

export default EmailIcon;
