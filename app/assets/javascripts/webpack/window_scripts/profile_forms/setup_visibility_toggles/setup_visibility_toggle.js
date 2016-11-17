export default function setupVisibilityToggle(parentFields, affected, recordType){
  const parentInputSelectors = parentFields.map(function(field){
    return parentInputSelector(recordType, field.name);
  }).join(", ");

  $(parentInputSelectors).change(function(e){
    doSideEffects(parentFields, affected, recordType);
  });
  doSideEffects(parentFields, affected, recordType)
}

const parentInputSelector = (recordType, fieldName) => {
  return `[name='${recordType}[${fieldName}]']`;
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
    $(`.${recordType}_${affected}`).hide();
  }
}

const typeAdjustedInputValue = (fieldname, recordType) => {
  const fields = $(parentInputSelector(recordType, fieldname))

  if (fields.filter("[type='checkbox']")[0]){
    // we do this because the hidden fields are dragged in too

    return fields.filter("[type='checkbox']").prop("checked");
  }
  else if (fields.attr("type") === "radio"){
    return fields.filter("[checked='checked']").val();
  }
  else {
    return fields.val();
  }
}
