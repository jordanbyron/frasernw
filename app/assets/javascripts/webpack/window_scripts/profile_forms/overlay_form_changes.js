export default function overlayFormDatasets(formOverlayConfig){
  if (formOverlayConfig.interactionType == 'rereview'){
    mimicBeforeUserEdit();
  }
  applyUserChanges();
}

const mimicBeforeUserEdit = (formOverlayConfig) => {
  overlayFormDataset(
    formOverlayConfig.baseReviewItem,
    [formOverlayConfig.recordType],
    { showPreviousValue: false }
  );
}

const applyUserChanges = (formOverlayConfig) => {
  overlayFormDataset(
    formOverlayConfig.reviewItem,
    [formOverlayConfig.recordType],
    { showPreviousValue: true }
  );
}

const overlayFormDataset = (formDataset, handlingPath, options) => {
  _.forEach(_.get(formDataset, handlingPath), (value, key) => {
    const newPath = handlingPath.concat(key)

    if (_.isPlainObject(value)){
      overlayFormDataset(formDataset, newPath, options)
    }
    else {
      overlayFormDatasetValue(newPath, value, options);
    }
  })
}

const overlayFormDatasetValue = (path, value, options) => {
  if (_.isArray(value)){
    overlayArrayValue(path, value, options)
  }
  else if (_.isString(value)){
    overlayStringValue(path, value, options);
  }
  else {
    raiseWithAlert(`Don't know how to handle the type of value at ${path}`);
  }
}

const overlayArrayValue = (path, value, options) => {
  $(`input:checkbox[name='${inputName(path)}[]']`).each((index, elem) => {
    if (_.includes(value, elem.value) && elem.checked === false){
      elem.checked = true;
      showPreviousValue($(elem), "unchecked", options)
    }
    else if (!_.includes(value, elem.value) && elem.checked == true){
      elem.checked = false;
      showPreviousValue($(elem), "checked", options)
    }
  })
}

const overlayStringValue = (path, value, options) => {
  const matchingElements = $(`*[name='${inputName(path)}']`);

  if (matchingElements.length > 1){
    if (_.every(matchingElements.toArray(), (input) => input.type === "radio")){
      const previouslyChecked = matchingElements.filter(":checked")[0];

      if (previouslyChecked.value !== value){
        $(matchingElements).filter(`[value='${value}'`)[0].checked = true;
        showPreviousValue($(previouslyChecked), "checked", options)
      }
    }
    else if (matchingElements.length === 2 &&
      matchingElements[0].type === "hidden" &&
      matchingElements[1].type === "checkbox"){

      if (value === "0" && matchingElements[1].checked){
        matchingElements[1].checked = false;
        showPreviousValue($(matchingElements[1]), "checked", options)
      }
      else if (value === "1" && !matchingElements[1].checked){
        matchingElements[1].checked = true;
        showPreviousValue($(matchingElements[1]), "unchecked", options)
      }
    }
    else {
      raiseWithAlert(`Can't handle multiple inputs for formdata path: ${path}`);
    }
  }
  else {
    const matchingElement = matchingElements[0]

    switch(matchingElement.tagName){
    case "INPUT":
      if(_.includes(["text", "tel", "email", "url"], matchingElement.type)){
        if (matchingElement.value !== value){
          showPreviousValue(
            $(matchingElement),
            (matchingElement.value === "" ? "blank" : matchingElement.value),
            options
          );

          matchingElement.value = value;
        }
      }
      else {
        raiseWithAlert(`Unrecognized input type found for path: ${path}`);
      }
      break;
    case "TEXTAREA":
      if (matchingElement.value.replace(textAreaRegexp, "") !==
        value.replace(textAreaRegexp, "")) {
        showPreviousValue(
          $(matchingElement),
          (matchingElement.value === "" ? "blank" : matchingElement.value),
          options
        )
        matchingElement.value = value;
      }
      break;
    case "SELECT":
      if (matchingElement !== value){
        //console.log("SELECT: old_entry_value = " + old_entry_value + ", new_entry_value = " + new_entry_value);
        showPreviousValue(
          $(matchingElement),
          (matchingElement.value == "" ?
            "blank" :
            $(matchingElement).find(`option[value='${matchingElement.value}'`).text()),
          options
        )
        matchingElement.value = value;
      }

      break;
    default:
      raiseWithAlert(`Unrecognized element tagname found for path: ${path}`);
    }
  }
}
const textAreaRegexp = /(\r\n|\n|\r)/gm;

const inputName = (formDatasetPath) => {
  return (
    formDatasetPath[0] +
    "[" +
    formDatasetPath.slice(1).join('][') +
    "]"
  )
}

const showPreviousValue = (formElement, previousValue, options) => {
  if(options.showPreviousValue){
    formElement.closest('div.control-group, div.changed_wrapper').addClass('changed');

    const annotation = $(document.createElement('span'));
    annotation.addClass('help-inline');
    annotation.text(`Was: ${previousValue}`);

    formElement.parent().append(annotation);
  }
}
