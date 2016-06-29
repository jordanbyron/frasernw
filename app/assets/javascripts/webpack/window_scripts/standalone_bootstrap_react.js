import React from "react";
import ReactDOM from "react-dom";

export default (component) => {
  return (containerId, props) => {
    $(document).ready(() => {
      // render the component
      ReactDOM.render(
        React.createElement(component, props),
        document.getElementById(containerId)
      );
    })
  };
}
