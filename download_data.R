library(purrr)
library(glue)
library(jsonlite)
source("utils.R")

# dirs for the data -------------------------------------------------
dir_output = "/data"

# get the cells -----------------------------------------------------------
cells = rondas::get_cells(4*4*4)

# safe version of queriying data ------------------------------------------
safe_fromJSON = purrr::safely(jsonlite::fromJSON)

# get raw data ----------------------------------------------------------------
regions_data = vector("list", length(length(cells)))

suppressWarnings({
  for (i in seq_along(cells)) {

    # cell
    cell = cells[[i]]

    #url
    url = glue(
      "https://services.surfline.com/kbyg/mapview?south={cell$south}&west={cell$west}&north={cell$north}&east={cell$east}"
    )

    # raw data
    raw_data = safe_fromJSON(url)

    if (!is.null(raw_data$error)) {
      next
    }

    raw_data = raw_data$result
    spots = raw_data$data$spots



    # # formt raw mapview data
    # formatted_data = rondas::format_raw_mapview_data(raw_data)

    # regions data
    regions_data[[i]] = spots


  }
})

# filter out nas
regions_data = regions_data[!is.na(regions_data)]


# bind together to make on big chunky df
all = bind_rows(regions_data)

# create path for the raw data
time_id = format(Sys.time(), "%Y_%m_%d_%H")

op = glue("{dir_output}/{time_id}.Rds")
if(file.exists(op)){
  unlink(op)
}

if(!dir.exists(dirname(op))){
  dir.create(dirname(op), recursive = T)
}

saveRDS(all, op)
