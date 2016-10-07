import _ from "lodash";

export const availabilityKnown = (record) => {
  return record.availabilityKnown;
}

export const unavailableForAwhile = (record) => {
  return !record.unavailableForAwhile;
}

export const matchesUserDivisions = (record, model) => {
  return _.intersection(
    record.availableToDivisionIds,
    model.app.currentUser.divisionIds
  ).pwPipe(_.any);
}

export const notHidden = (record, model) => {
  return model.app.currentUser.role !== "user" ||
    !record.hidden;
}
