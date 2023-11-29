# Assess intrinsic quality of an Arrow Table
Follow the quality framework by [Schmidt et. al. (2019)](https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/s12874-021-01252-7)

--- 
## Define metadata
Metadata is where users define a set of rules to validate the dataset.   
Must be 2 excel files stored in the same folder.
- item level metadata: store information about each variable in the dataset
- cross item level metadata: store information about the correlation between variables in the dataset

### Item level metadata
Excel file containing the following fields
- variable (required) - name of the variables in the dataset
- datatype (required): either float, integer, string, logical or datetime
- limit: plausible range for data use "[" "]" for inclusive range or "(", ")" otherwise. If there is no upper limit/ lower limit then leave it blank (e.g. [10, )). Dates must be in dmy format.
- labels (only for categorical data): points to another sheet (in the same worksheet) containing onec column named "labels" OR list of labels separated by \| (e.g. "male | female", "positive | negative | neutral")
- missing_labels: list of label for missing data, separated by |

### Cross-item level metadata 
Excel file containing 2 sheets
1st sheet - listing multivariate combinations to be checked, containing following fields
- variables: list of multivariate variables, separated by |
- label: label for a multivariate combination, used to refer that combination in other sheets
- check_duplicates: Whether to check duplicates, either True or False
- check_missing: Whether to check multivariate missingness, either True or False


2nd sheet - listing contradictory rules, containing the following fields
- label: label of the multivarite check
- contradiction: define rules following the convention of R conditions (e.g. vacdate > dob)

--- 
## Reference manual

### Read metadata
```
# read item metadata
item_metadata <- prep_item_metadata(path = path_to_metadata_folder)
# read cross item metadata
cross_item_metadata <- prep_crossitem_metadata(path = path_to_metadata_folder)
```

### Assess Integrity
```
# check and parse to the defined datatype, return the parsed arrow table
# specify date format if necessary
arrow_data <- int_datatype(arrow_data, item_metadata, date_format = "%d%m%Y")

# check for multivariate duplicates
# return a result dataframe and a list of boolean indicating whether each row is a duplicate
int_duplicates(arrow_data, cross_item_metadata = cross_item_metadata)
```

### Assess Consistency
```
# check range of value
# return a result dataframe
con_range(arrow_data, item_level, plot_result = TRUE)

# check labels 
# return a result dataframe
con_label(arrow_data, metadata = item_level, path=metadata_path)

# check number of records that contradict with predefined rules
# return result dataframe and records with contradictions
contradiction_result <- con_contradiction(arrow_data, metadata = cross_item_metadata)

# access record with contradiction using the label defined in cross item metadata
contradiction_result$contradiction_label
```

### Assess Completeness
```
# crude missing - count the number of NA data for each feature and any multivariate the user have defined
# return 2 dataframes for univariate and multivariate check
result <- com_crude_missing(arrow_data, item_metadata = item_level, cross_item_metadata = cross_item_level)

# view result 
result$univariate_result
result$multivariate_result

# qualified missing - count the number of data with missing labels
# return result dataframe for univariate missing
com_crude_missing(arrow_data, item_metadata = item_level, cross_item_metadata = cross_item_level)
```

### Assess Accuracy
```
# check number of Tukey outliers.
# return result dataframe and records with outliers 
accuracy_result <- acc_uni_outliers(arrow_data, item_level)

# view result dataframe
accuracy_result$result

# view records with outliers
accuracy_result$outliers$var_1 %>% collect()
accuracy_result$outliers$var_2  %>% collect()
```


