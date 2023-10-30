--- 
title: "Document for DQA toolkit"
---

# Format of metadata

## Item level metadata
Expected to be an excel file containing the following fields
- variable (required)
- datatype (required): either float, integer, string or datetime
- limit: plausible range for data use "[" "]" for inclusive range or "(", ")" otherwise. If there is no upper limit/ lower limit then leave it blank (e.g. [10, ))
- labels (only for categorical data): points to another sheet (in the same worksheet) containing onec column named "labels" OR list of labels separated by | (e.g. "male | female", "positive | negative | neutral")
- missing_labels: list of label for missing data, separated by |

## Cross-item level metadata 
Excel file containing 2 sheets
1st sheet - listing multivariate combinations to be checked, containing following fields
- variables: list of multivariate variables, separated by |
- label: label for a multivariate combination, used to refer that combination in other sheets
- check_outlier: Whether to check outliers, either True or False
- check_duplicates: Whether to check dupicates, either True or False
- check_missing: Whether to check multivariate missingness, either True or False


2nd sheet - listing contradictory rules, containing the following fields
- Label: label of the multivarite check
- Contradiction: define rules (e.g. vacdate > dob)


