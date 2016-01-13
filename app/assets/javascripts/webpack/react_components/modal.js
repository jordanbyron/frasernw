import React from "react";

const Modal = (props) => {
  if(props.isVisible) {
    return(
      <div className="modal__background">
        <div className="modal__body">
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
