export default {
  contentCategories: function(): Array {
    return [
      { label: "Title", key: "TITLE" },
      { label: "Category", key: "SUBCATEGORY" },
      { label: "", key: "FAVOURITE" },
      { label: "", key: "EMAIL_TO_PATIENT" },
      { label: "", key: "PROVIDE_FEEDBACK" }
    ];
  },
  referents: function(labelName: string, includingOtherSpecializations: boolean): Array {
    if (includingOtherSpecializations) {
      return [
        { label: labelName, key: "NAME", className: "specialization_table__th--name" },
        { label: "Specialties", key: "SPECIALTIES", className: "specialization_table__th--specialties" },
        { label: "Accepting New Referrals?", key: "REFERRALS", className: "specialization_table__th--referrals" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME", className: "specialization_table__th--waittime" },
        { label: "City", key: "CITY", className: "specialization_table__th--city" }
      ];
    } else {
      return [
        { label: labelName, key: "NAME", className: "specialization_table__th--name" },
        { label: "Accepting New Referrals?", key: "REFERRALS", className: "specialization_table__th--referrals" },
        { label: "Average Non-urgent Patient Waittime", key: "WAITTIME", className: "specialization_table__th--waittime" },
        { label: "City", key: "CITY", className: "specialization_table__th--city" }
      ];
    }
  }
};
