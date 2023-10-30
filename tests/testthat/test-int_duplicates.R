test_that("Test pipe",{
  reticulate::use_condaenv("vaccine_reg")
  first_col <- c("some_string", NA, "smth else")
  second_col <- c(NA, "other", NA)
  
  dummy_dataframe <- as.data.frame(first_col, second_col)
  dummy_data <- as_arrow_table(dummy_dataframe)
  
  expect_no_error(dummy_data %>% util_compute_distincts(c("first_col")))
  
})