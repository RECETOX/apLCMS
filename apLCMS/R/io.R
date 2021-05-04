.check_hdf5r_package <- function() {
  if (!requireNamespace("hdf5r", quietly = TRUE))
    stop("Package \"hdf5r\" is needed for this functionality. Please install it.", call. = FALSE)
}

load_known_table_from_hdf <- function(path) {
  .check_hdf5r_package()

  file <- hdf5r::H5File$new(path, mode = "r")
  on.exit(file$close_all())

  if (!"aplcms_known_table" %in% names(file))
    stop("No group named \"aplcms_known_table\" in ", path, " file!")
  as.data.frame(file[["aplcms_known_table"]]$read())
}

save_known_table_to_hdf <- function(path, known_table) {
  .check_hdf5r_package()

  file <- hdf5r::H5File$new(path, mode = "w")
  on.exit(file$close_all())

  file[["aplcms_known_table"]] <- known_table
  invisible(known_table)
}

save_peaks_to_hdf <- function(file, peaks) {
  .check_hdf5r_package()

  file <- hdf5r::H5File$new(file, mode = "w")
  on.exit(file$close_all())

  file[["peaks"]] <- peaks$final_peaks
  file[["aligned_peaks"]] <- peaks$aligned_peaks
  file[["corrected_features"]] <- peaks$corrected_features
  file[["extracted_features"]] <- peaks$extracted_features
  file[["aligned_mz_tolerance"]] <- peaks$aligned_mz_tolerance
  file[["aligned_rt_tolerance"]] <- peaks$aligned_rt_tolerance
  invisible(peaks)
}
