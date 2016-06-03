import ReactDOM from "react-dom";
import React from "react";
import SecretEditLinks from "controllers/secret_edit_links";

export default function(config) {
  let container = document.getElementById(config.containerId);
  ReactDOM.render(<SecretEditLinks {...config.props}/>, container);
}
