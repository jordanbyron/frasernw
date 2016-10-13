export default function setupVisibilityToggle(parentFields, affected, recordType){
  const parentInputSelector = parentFields.map(function(field){
    return `#${recordType}_${field.name}`;
  }).join(", ");

  $(parentInputSelector).change(function(e){
    doSideEffects(parentFields, affected, recordType);
  });
  doSideEffects(parentFields, affected, recordType)
}

const doSideEffects = (parentFields, affected, recordType) => {
  if(parentFields.every(function(field) {
    return typeAdjustedInputValue(field.name, recordType) == field.truthyVal
  })){
    showAffected(affected, recordType);
  }
  else {
    hideAffected(affected, recordType);
  }
}

const showAffected = (affected, recordType) => {
  if(affected.indexOf("section") !== -1){
    $(`#${affected}`).show();
  }
  else{
    $(`.${recordType}_${affected}`).show()
  }
}

const hideAffected = (affected, recordType) =>{
  if(affected.indexOf("section") !== -1){
    $(`#${affected}`).hide();
  }
  else{
    $(`.${recordType}_${affected}`).
      hide()

    const childCheckbox = $(`#${recordType}_${affected}`)[0]
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
