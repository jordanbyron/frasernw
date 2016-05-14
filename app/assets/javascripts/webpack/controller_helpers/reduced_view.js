export function viewSelectorClass(model, viewKey){
  if (reducedView(model) === viewKey){
    return "";
  }
  else {
    return "hide-when-reduced";
  }
}

export function reducedView(model){
  return model.ui.reducedView || "main";
}

export default reducedView;
