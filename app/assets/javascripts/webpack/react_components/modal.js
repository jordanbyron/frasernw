import React from "react";

const backgroundStyles = {
  backgroundColor: "rgba(119, 119, 119, 0.25)",
  position: "fixed",
  top: "0px",
  left: "0px",
  right: "0px",
  bottom: "0px",
}

const modalStyles = {
  position: "absolute",
  top: "20%",
  left: "20%",
  width: "60%",
  backgroundColor: "white",
  padding: "30px",
  boxShadow: "2px 2px 8px #888"
}

const Modal = (props) => {
  if(props.isVisible) {
    return(
      <div style={backgroundStyles}>
        <div style={modalStyles}>
          { props.renderContents() }
        </div>
      </div>
    );
  } else {
    return(
      <div></div>
    );
  }
}

export default Modal;
