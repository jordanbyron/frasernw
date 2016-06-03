import React from "react";

const Modal = ({isVisible, renderContents}) => {
  if(isVisible) {
    return(
      <div className="modal__background">
        <div className="modal__body">
          { renderContents() }
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
