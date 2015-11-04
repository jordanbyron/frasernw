import TableHeadingGenerators from "state_mappers/filter_table/table_headings_generators";

export default function(state, dispatch) {
  console.log(state);
  if(state.ui.hasBeenInitialized) {
    return {
      filters: {
        title: `Filter ${state.app.contentCategories[state.ui.contentCategoryId].name}`,
        groups: [],
      },
      tableHead: {
        data: TableHeadingGenerators.contentCategories(),
        sortConfig: sortConfig(state),
      },
      dispatch: dispatch,
    };
  }
  else {
    return { isLoading: true };
  }
};


const sortConfig = (state) => ({
  order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
  column: _.get(state, ["ui", "sortConfig", "column"], "TITLE"),
})
