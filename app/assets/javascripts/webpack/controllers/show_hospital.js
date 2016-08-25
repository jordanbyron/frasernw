import React from "react";
import { matchedRoute, recordShownByRoute } from "controller_helpers/routing";

const ShowHospital = ({model}) => {
  if(matchedRoute(model) === "/hospitals/:id"){
    return(
      <div>
        <AddressLink model={model}/>
        <p className="no_indent">{ recordShownByRoute(model).phoneAndFax }</p>
      </div>
    )
  }
  else {
    return <noscript/>
  }
}

const AddressLink = ({model}) => {
  if(recordShownByRoute(model).address && recordShownByRoute(model).mapUrl){
    return(
      <p className="no_indent">
        <a href={recordShownByRoute(model).mapUrl}
          target="_blank"
        >{ recordShownByRoute(model).address }</a>
      </p>
    )
  }
  else {
    return <noscript/>
  }
}

export default ShowHospital
