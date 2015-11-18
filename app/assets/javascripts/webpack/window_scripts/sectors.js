import _ from "lodash";

const infoAvailable = (sectorWrapper) => (
  $(sectorWrapper).find(".sector_info_available_input")[0].checked
)

const setDisabled = (sectorWrapper, disabledVal) => {
  $(sectorWrapper).find(".sector_type_input").attr("disabled", disabledVal);
}

const setVisibility = (sectorWrapper, visibility) => {
  $(sectorWrapper).find(".sector_type_inputs").toggle(visibility);
}

const updateDom = () => {
  _.each($(".sector_wrapper"), (wrapper) => {
    setVisibility(wrapper, infoAvailable(wrapper));
  })
}

export default function() {
  $(document).ready(() => {
    $(".sector_info_available_input").change(updateDom);
    updateDom();
  })
}
