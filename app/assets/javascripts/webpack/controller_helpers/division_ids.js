const divisionIds = (model, profile) => {
  return profile.
    cityIds.
    map((id) => model.app.cities[id].divisionsEncompassingIds).
    pwPipe(_.flatten);
}

export default divisionIds
