# Script adapted from original by Wytamma Wirth:
#   https://github.com/Wytamma/real-time-beast-pipeline/blob/master/01_download_sequences_GISAIDR.R

args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  print(args)
  stop("Incorrect number of arguments. Expected: <output_basename> <downsample_factor>.n", call.=FALSE)
}
basename <- args[1]
down_sample <- as.numeric(args[2])

library(GISAIDR)
library(tidyverse)

username = Sys.getenv("GISAIDR_USERNAME")
password = Sys.getenv("GISAIDR_PASSWORD")
credentials <- login(username = username, password = password)

# VOC Omicron GRA (B.1.1.529+BA.*) first detected in Botswana/Hong Kong/South Africa
Omicron_df <- query(
  credentials = credentials,
  lineage = "BA.1",
  location = "Australia / Victoria",
  collection_date_complete = T,
  complete = T,
  low_coverage_excl = T,
  load_all = T
)

Omicron_df_sampled <-
  Omicron_df %>% slice_sample(n = nrow(Omicron_df) / down_sample)

credentials <-
  login(username, password)

Omicron_df <- download(
  credentials = credentials,
  list_of_accession_ids = Omicron_df_sampled$accession_id,
  get_sequence = T
)

Omicron_df$date <- as.Date(Omicron_df$date)

# sort by date
Omicron_df <- Omicron_df[order(Omicron_df$date), ]

export_fasta(
  Omicron_df,
  out_file_name = sprintf('%s-original.fasta', basename),
  export_dated_only = T,
  date_format = '%Y-%m-%d'
)
