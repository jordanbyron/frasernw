import TableHeadingGenerators from "state_mappers/filter_table/table_headings_generators";

export default function(state, dispatch) {
  console.log(state);
  if(state.ui.hasBeenInitialized) {
    return {
      bodyRows: [],
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


const sortConfig = (state) => ({
  order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
  column: _.get(state, ["ui", "sortConfig", "column"], "TITLE"),
})
