import _ from "lodash";

const infoAvailable = (sectorWrapper) => (
  sectorWrapper.children(".sector_info_available_input")[0].checked
)

const setDisabled = (sectorWrapper, disabledVal) => {
  sectorWrapper.children(".sector_type_input").attr("disabled", disabledVal);
}

const updateDom = () => {
  _.each($(".sector_wrapper"), (wrapper) => {
    console.log(infoAvailable(wrapper));
    setDisabled(wrapper, !infoAvailable(wrapper));
  })
}

export default function() {
  console.log(0);
  $(document).ready(() => {
    console.log(1);
    $(".sector_info_available_input").change(updateDom())
    updateDom()
  })
}
