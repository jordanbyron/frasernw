export function locationChanged(newLocation) {
  return {
    type: "LOCATION_CHANGED",
    newLocation: newLocation
  };
};
