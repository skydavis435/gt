#' Create a **gt** table object
#'
#' The `gt()` function creates a **gt** table object when provided with table
#' data. Using this function is the first step in a typical **gt** workflow.
#' Once we have the **gt** table object, we can perform styling transformations
#' before rendering to a display table of various formats.
#'
#' There are a few data ingest options we can consider at this stage. We can
#' choose to create a table stub with rowname captions using the `rowname_col`
#' argument. Further to this, stub row groups can be created with the
#' `groupname_col`. Both arguments take the name of a column in the input table
#' data. Typically, the data in the `groupname_col` will consist of categories
#' of data in a table and the data in the `rowname_col` are unique labels
#' (perhaps unique across the entire table or unique within groups).
#'
#' Row groups can also be created by passing a `grouped_df` to `gt()` by using
#' the [dplyr::group_by()] function on the table data. In this way, two or more
#' columns of categorical data can be used to make row groups. The
#' `row_group.sep` argument allows for control in how the row group label will
#' appear in the display table.
#'
#' @param data A `data.frame` object or a tibble.
#' @param rowname_col The column name in the input `data` table to use as row
#'   captions to be placed in the display table stub. If the `rownames_to_stub`
#'   option is `TRUE` then any column name provided to `rowname_col` will be
#'   ignored.
#' @param groupname_col The column name in the input `data` table to use as
#'   group labels for generation of stub row groups. If the input `data` table
#'   has the `grouped_df` class (through use of the [dplyr::group_by()] function
#'   or associated `group_by*()` functions) then any input here is ignored.
#' @param rownames_to_stub An option to take rownames from the input `data`
#'   table as row captions in the display table stub.
#' @param auto_align Optionally have column data be aligned depending on the
#'   content contained in each column of the input `data`. Internally, this
#'   calls `cols_align(align = "auto")` for all columns.
#' @param id The table ID. By default, with `NULL`, this will be a random,
#'   ten-letter ID as generated by using the [random_id()] function. A custom
#'   table ID can be used with any single-length character vector.
#' @param row_group.sep The separator to use between consecutive group names (a
#'   possibility when providing `data` as a `grouped_df` with multiple groups)
#'   in the displayed stub row group label.
#'
#' @return An object of class `gt_tbl`.
#'
#' @examples
#' # Create a table object using the
#' # `exibble` dataset; use the `row`
#' # and `group` columns to add a stub
#' # and row groups
#' tab_1 <-
#'   exibble %>%
#'   gt(
#'     rowname_col = "row",
#'     groupname_col = "group"
#'   )
#'
#' # The resulting object can be used
#' # in transformations (with `tab_*()`,
#' # `fmt_*()`, `cols_*()` functions)
#' tab_2 <-
#'   tab_1 %>%
#'   tab_header(
#'     title = "Table Title",
#'     subtitle = "Subtitle"
#'   ) %>%
#'   fmt_number(
#'     columns = vars(num),
#'     decimals = 2
#'   ) %>%
#'   cols_label(num = "number")
#'
#' @section Figures:
#' \if{html}{\figure{man_gt_1.svg}{options: width=100\%}}
#'
#' \if{html}{\figure{man_gt_2.svg}{options: width=100\%}}
#'
#' @family Create Table
#' @section Function ID:
#' 1-1
#'
#' @export
gt <- function(data,
               rowname_col = "rowname",
               groupname_col = dplyr::group_vars(data),
               rownames_to_stub = FALSE,
               auto_align = TRUE,
               id = NULL,
               row_group.sep = getOption("gt.row_group.sep", " - ")) {

  # Stop function if the supplied `id` doesn't conform
  # to character(1) input or isn't NULL
  validate_table_id(id)

  if (rownames_to_stub) {
    # Just a column name that's unlikely to collide with user data
    rowname_col <- "__GT_ROWNAME_PRIVATE__"
  }

  if (length(groupname_col) == 0) {
    groupname_col <- NULL
  }

  # Stop function if `rowname_col` and `groupname_col`
  # have the same string values
  if (!is.null(rowname_col) &&
      !is.null(groupname_col) &&
      any(rowname_col %in% groupname_col)) {

    stop("The value \"", rowname_col, "\" appears in both `rowname_col` and ",
         "`groupname_col`. These arguments must not have any values in common.",
         call. = FALSE)
  }

  # Initialize the main objects
  data <-
    list() %>%
    dt_data_init(
      data_tbl = data,
      rownames_to_column = if (rownames_to_stub) rowname_col else NA_character_
    ) %>%
    dt_boxhead_init() %>%
    dt_stub_df_init(
      rowname_col = rowname_col,
      groupname_col = groupname_col,
      row_group.sep = row_group.sep
    ) %>%
    dt_row_groups_init() %>%
    dt_stub_others_init() %>%
    dt_heading_init() %>%
    dt_spanners_init() %>%
    dt_stubhead_init() %>%
    dt_footnotes_init() %>%
    dt_source_notes_init() %>%
    dt_formats_init() %>%
    dt_styles_init() %>%
    dt_summary_init() %>%
    dt_options_init() %>%
    dt_transforms_init() %>%
    dt_has_built_init()

  # Add any user-defined table ID to the `table_id` parameter
  # (if NULL, the default setting will generate a random ID)
  if (!is.null(id)) {
    data <- data %>% dt_options_set_value(option = "table_id", value = id)
  }

  # Apply the `gt_tbl` class to the object while
  # also keeping the `data.frame` class
  class(data) <- c("gt_tbl", class(data))

  # If automatic alignment of values is to be done, call
  # the `cols_align()` function on data
  if (isTRUE(auto_align)) {
    data <- data %>% cols_align(align = "auto")
  }

  data
}
