var React = require("react");

var labelReferentName = function(record) {
  return (
    <a href={"/" + record.collectionName + "/" + record.id}>{ record.name }</a>
  );
}

var labelReferentStatus = function(record) {
  return (
    <i className={record.statusIconClasses}></i>
  );
}

var labelReferentCities = function(record, labels) {
  return record
    .cityIds
    .map((id) => labels.city[id])
    .join(" and ");
}

var labelReferentSpecialties = function(record, labels) {
  return record
    .specializationIds
    .map((id) => labels.specialties[id])
    .join(" and ");
}

module.exports = {
  referents: function(record, labels) {
    return {
      cells: [
        labelReferentName(record),
        labelReferentSpecialties(record, labels),
        labelReferentStatus(record),
        record.waittime,
        labelReferentCities(record, labels)
      ],
      reactKey: (record.collectionName + record.id),
      record: record
    }
  },
  resources: function(record, labels) {
    return {
      cells: [
        record.title,
        labels.scCategories[record.scCategoryId],
        "",
        "",
        ""
      ],
      reactKey: (record.collectionName + record.id),
      record: record
    }
  }
}
