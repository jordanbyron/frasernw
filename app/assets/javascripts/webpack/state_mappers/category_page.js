import TableHeadingGenerators from "state_mappers/filter_table/table_headings_generators";
import { from } from "utils";
import RowGenerators from "state_mappers/filter_table/row_generators";
import itemsForCategory from "domain/content_category_items";
import SortFunctions from "state_mappers/filter_table/sort_functions";
import SortOrders from "state_mappers/filter_table/sort_orders";
import Filters from "state_mappers/filter_table/filters"
import resultSummary from "state_mappers/filter_table/generate_result_summary"
import anyFiltersActivated from "state_mappers/filter_table/any_filters_activated"

export default function(state, dispatch) {
  console.log(state);

  if(state.ui.hasBeenInitialized) {
    const _divisionIds = divisionIds(state);
    const _maskingSet =
      itemsForCategory(state.ui.contentCategoryId, state, _divisionIds);
    const _sortConfig = sortConfig(state);
    const _filterValues =
      _.mapValues(FilterValues, (value) => value(state, _maskingSet));
    const _bodyRows =
      bodyRows(state, dispatch, _sortConfig, _maskingSet, _filterValues)
    const _category = state.app.contentCategories[state.ui.contentCategoryId];

    const _resultSummary = resultSummary({
      app: state.app,
      bodyRows: _bodyRows,
      labelName: _category.name.toLowerCase(),
      panelTypeKey: "contentCategories",
      referralCities: [],
      filterValues: _filterValues,
      availableFilters: operativeFilterKeys
    });

    return {
      bodyRows: _bodyRows,
      resultSummary: {
        anyResults: (_bodyRows.length > 0),
        isVisible: (_resultSummary.length > 1),
        text: _resultSummary,
        showClearButton: anyFiltersActivated(state.ui.filterValues)
      },
      cityFilterPills: { shouldDisplay: false },
      specializationFilterMessage: { shouldDisplay: false },
      assumedList: { shouldDisplay: false },
      reducedView: _.get(state, ["ui", "reducedView"], "main"),
      sortConfig: _sortConfig,
      headings: TableHeadingGenerators.contentCategories(),
      // TODO name this 'sidebarFilteringSection'
      filters: {
        title: `Filter ${_category.name}`,
        // TODO: name this 'sidebarFilteringSectionGroups'
        groups: _.map(FilterGroups, (group) => group(state, _filterValues)),
      },
      dispatch: dispatch
    }
  }
  else {
    return { isLoading: true };
  }
};

const operativeFilterKeys = ["subcategories", "specializations"];
const bodyRows = (state, dispatch, sortConfig, maskingSet, filterValues) => {
  const _operativeFilters = _.values(_.pick(Filters, operativeFilterKeys))
    .filter((filter) => filter.isActivated(filterValues))
    .map(_.property("predicate"));

  return from(
    _.partialRight(_.sortByOrder, SortFunctions.contentCategories(sortConfig), SortOrders.contentCategories(sortConfig)),
    _.partialRight(_.map, _.partial(RowGenerators.resources, state.app, dispatch, { panelKey: 0 })),
    _.partialRight(_.filter, (record) => _.every(_operativeFilters, (filter) => filter(record, filterValues))),
    maskingSet
  );
};

const divisionIds = (state) => {
  if(state.app.currentUser.isSuperAdmin) {
    return _.values(state.app.divisions).map(_.property("id"));
  }
  else {
    return state.app.currentUser.divisionIds;
  }
}

const sortConfig = (state) => ({
  order: _.get(state, ["ui", "sortConfig", "order"], "DOWN"),
  column: _.get(state, ["ui", "sortConfig", "column"], "TITLE"),
})

const FilterValues = {
  subcategories: function(state, maskingSet) {
    return _.chain(maskingSet)
     .map((record) => record.categoryId)
     .flatten()
     .uniq()
     .without(state.ui.contentCategoryId)
     .reduce((memo, id) => {
       return _.assign(
         { [id]: _.get(state, ["ui", "filterValues", "subcategories", id], false) },
         memo
       );
     }, {})
     .value();
  },
  specializations: function(state, maskingSet) {
    const assignValues = _.partialRight(_.reduce, (memo, id) => {
      return _.assign(
        { [id]: _.get(state, ["ui", "filterValues", "specializations", id], false) },
        memo
      );
    }, {});

    return from(
      assignValues,
      _.uniq,
      _.flatten,
      _.partialRight(_.map, _.property("specializationIds")),
      maskingSet
    );
  }
}

const FilterGroups = {
  specializations: function(state: Object, filterValues: Object): Object {
    return {
      filters: {
        specializations: _.map(
          filterValues.specializations,
          function(value: boolean, specializationId: string) {
            return {
              filterId: specializationId,
              label: state.app.specializations[specializationId].name,
              value: value
            };
          }
        ),
      },
      title: "Specialties",
      isOpen: _.get(state, ["ui" ,"filterGroupVisibility", "specializations"], true),
      shouldDisplay: _.any(_.keys(filterValues.specializations)),
      componentKey: "specializations",
    };
  },
  subcategories: function(state: Object, filterValues: Object): Object {
    return {
      filters: {
        subcategories: _.map(
          filterValues.subcategories,
          function(value: boolean, subcategoryId: string) {
            return {
              filterId: subcategoryId,
              label: state.app.contentCategories[subcategoryId].name,
              value: value
            };
          }
        ),
      },
      title: "Subcategories",
      isOpen: _.get(state, ["ui" ,"filterGroupVisibility", "subcategories"], true),
      shouldDisplay: _.any(_.keys(filterValues.subcategories)),
      componentKey: "subcategories",
    };
  },
}
