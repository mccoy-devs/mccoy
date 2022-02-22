# Script adapted from original by Wytamma Wirth:
#   https://github.com/Wytamma/real-time-beast-pipeline/blob/master/01_download_sequences_GISAIDR.R

args = commandArgs(trailingOnly=TRUE)
if (length(args)!=3) {
  print(args)
  stop("Incorrect number of arguments. Expected: <output_basename> <to_date> <downsample_factor>.n", call.=FALSE)
}
basename <- args[1]
to_date <- args[2]
down_sample <- as.numeric(args[3])

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
  to = to_date,
  collection_date_complete = T,
  complete = T,
  low_coverage_excl = T,
  load_all = T
)

Omicron_df$date <- as.Date(Omicron_df$collection_date)

Omicron_df_sampled <-
  Omicron_df %>% slice_sample(n = nrow(Omicron_df) / down_sample)

Omicron_df_sampled %>%
  ggplot(aes(x = date)) +
  geom_bar(aes(y = cumsum(..count..)),
           fill = "#69b3a2",
           color = "#e9ecef",
           alpha = 0.8)
ggsave(sprintf("%s-full_%s-dates.png", basename, to_date))

credentials <-
  login(username, password)

Omicron_df_full <- download(
  credentials = credentials,
  list_of_accession_ids = Omicron_df_sampled$accession_id,
  get_sequence = T
)

Omicron_df_full$date <- as.Date(Omicron_df_full$date)

# sort by date
Omicron_df_full <- Omicron_df_full[order(Omicron_df_full$date), ]

export_fasta(
  Omicron_df_full,
  out_file_name = sprintf('%s-full_%s.fasta', basename, to_date),
  export_dated_only = T,
  date_format = '%Y-%m-%d'
)

export_fasta(
  Omicron_df_full %>%
    filter(date < as.Date(to_date)),
  out_file_name = sprintf('%s-before_%s.fasta', basename, to_date),
  export_dated_only = T,
  date_format = '%Y-%m-%d'
)
