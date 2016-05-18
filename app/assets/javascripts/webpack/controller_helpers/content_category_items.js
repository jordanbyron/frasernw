import _ from "lodash";
import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";
import { matchesRoute, matchesTab } from "controller_helpers/collection_shown";

export default function(categoryId, model){
  return model.
    app.
    contentItems.
    pwPipe(_.values).
    filter((item) => {
      return _.intersection(
        item.availableToDivisionIds,
        model.app.currentUser.divisionIds
      ).pwPipe(_.any) &&
        matchesRoute(item, model) &&
        matchesTab(item, model, `contentCategory${categoryId}`);
    })
};
