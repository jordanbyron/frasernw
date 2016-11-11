import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { memoizePerRender } from "utils";

export const currentPage = ((model) => {
  return _.get(
    model,
    [ "ui", "tabs", selectedTabKey(model), "currentPage"],
    1
  );
}).pwPipe(memoizePerRender)

export const ROWS_PER_PAGE = 30;

export const paginate = (model, records) => {
  return records.slice(
    ((currentPage(model) - 1) * ROWS_PER_PAGE),
    (currentPage(model) * ROWS_PER_PAGE)
  );
}
