import React from "react";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";

const ShowHospital = ({model}) => {
  if(matchedRoute(model) === "/hospitals/:id"){
    return(
      <div>
        <AddressLink model={model}/>
        <p className="no_indent">{ recordShownByPage(model).phoneAndFax }</p>
      </div>
    )
  }
  else {
    return <noscript/>
  }
}

const AddressLink = ({model}) => {
  if(recordShownByPage(model).address && recordShownByPage(model).mapUrl){
    return(
      <p className="no_indent">
        <a href={recordShownByPage(model).mapUrl}
          target="_blank"
        >{ recordShownByPage(model).address }</a>
      </p>
    )
  }
  else {
    return <noscript/>
  }
}

export default ShowHospital
