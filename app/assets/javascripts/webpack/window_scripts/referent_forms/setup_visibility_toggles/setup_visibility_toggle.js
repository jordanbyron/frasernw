export default function setupVisibilityToggle(parentFields, effected, recordType){
  const parentInputSelector = parentFields.map(function(field){
    return `#${recordType}_${field.name}`;
  }).join(", ");

  $(parentInputSelector).change(function(e){
    doSideEffects(parentFields, effected, recordType);
  });
  doSideEffects(parentFields, effected, recordType)
}

const doSideEffects = (parentFields, effected, recordType) => {
  if(parentFields.every(function(field) {
    return typeAdjustedInputValue(field.name, recordType) == field.truthyVal
  })){
    showEffected(effected, recordType);
  }
  else {
    hideEffected(effected, recordType);
  }
}

const showEffected = (effected, recordType) => {
  if(effected.indexOf("section") !== -1){
    $(`#${effected}`).show();
  }
  else{
    $(`.${recordType}_${effected}`).show()
  }
}

const hideEffected = (effected, recordType) =>{
  if(effected.indexOf("section") !== -1){
    $(`#${effected}`).hide();
  }
  else{
    $(`.${recordType}_${effected}`).
      hide()

    const childCheckbox = $(`#${recordType}_${effected}`)[0]
    if (childCheckbox){
      $(childCheckbox).attr("checked", false)
    }
  }
}

const typeAdjustedInputValue = (fieldname, recordType) => {
  const field = $(`#${recordType}_${fieldname}`)

  if (field.attr("type") === "checkbox"){
    return field.prop("checked");
  }
  else {
    return field.val();
  }
}
