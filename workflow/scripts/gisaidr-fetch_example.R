# Script adapted from original by Wytamma Wirth:
#   https://github.com/Wytamma/real-time-beast-pipeline/blob/master/01_download_sequences_GISAIDR.R

library(GISAIDR)
library(tidyverse)
library(yaml)

args = commandArgs(trailingOnly=TRUE)
if (length(args)!=2) {
  print(args)
  stop("Incorrect number of arguments. Expected: <config_file> <output_basename>.n", call.=FALSE)
}
conf_file <- args[1]
basename <- args[2]

username = Sys.getenv("GISAIDR_USERNAME")
password = Sys.getenv("GISAIDR_PASSWORD")
credentials <- login(username = username, password = password)

conf <- yaml.load_file(conf_file)
query_args = conf$gisaid
query_args$load_all = T
query_args$credentials = credentials

Omicron_df <- do.call("query", query_args)

down_sample <- conf$downsample
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
