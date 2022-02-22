args = commandArgs(trailingOnly=TRUE)
if (length(args)!=1) {
  stop("Only one argument may/must be supplied (output file).n", call.=FALSE)
}

library(GISAIDR)

username = Sys.getenv("GISAIDR_USERNAME")
password = Sys.getenv("GISAIDR_PASSWORD")
credentials <- login(username = username, password = password)

df <- query(
    credentials = credentials, 
    location = 'Australia',
    from_subm = '2022-01-01',
    to_subm = '2022-02-22',
    complete = T,
    low_coverage_excl = T,
    collection_date_complete = T,
    nrows = 50
)

full_df_with_seq <- download(
    credentials = credentials, 
    list_of_accession_ids = df$accession_id, 
    get_sequence=T
)

export_fasta(full_df_with_seq,
    export_dated_only = T,
    date_format = '%Y-%m-%d',
    out_file_name = args[1]
)
