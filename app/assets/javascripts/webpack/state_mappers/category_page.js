import TableHeadingGenerators from "state_mappers/filter_table/table_headings_generators";
import { from } from "utils";
import RowGenerators from "state_mappers/filter_table/row_generators";
import itemsForCategory from "domain/content_category_items";

export default function(state, dispatch) {
  console.log(state);
  if(state.ui.hasBeenInitialized) {
    return {
      bodyRows: bodyRows(state, dispatch),
      resultSummary: { isVisible: false },
      cityFilterPills: { shouldDisplay: false },
      specializationFilterMessage: { shouldDisplay: false },
      assumedList: { shouldDisplay: false },
      reducedView: _.get(state, ["ui", "reducedView"], "main"),
      sortConfig: sortConfig(state),
      headings: TableHeadingGenerators.contentCategories(),
      // TODO name this 'sidebarFilteringSection'
      filters: {
        title: `Filter ${state.app.contentCategories[state.ui.contentCategoryId].name}`,
        // TODO: name this 'sidebarFilteringSectionGroups'
        groups: []
      },
      dispatch: dispatch
    }
  }
  else {
    return { isLoading: true };
  }
};

const bodyRows = (state, dispatch) => {

  if(state.app.currentUser.isSuperAdmin) {
    var _divisionIds = _.values(state.app.divisions).map(_.property("id"));
  }
  else {
    var _divisionIds = state.app.currentUser.divisionIds;
  }
  console.log(_divisionIds);
  console.log(itemsForCategory(state.ui.contentCategoryId, state, _divisionIds));

  return from(
    _.partialRight(_.map, _.partial(RowGenerators.resources, state.app, dispatch, { panelKey: 0 })),
    itemsForCategory(state.ui.contentCategoryId, state, _divisionIds)
  );
}

const sortConfig = (state) => ({
  order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
  column: _.get(state, ["ui", "sortConfig", "column"], "TITLE"),
})
