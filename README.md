# Tidier Open Government

> A collection of R scripts that produce tidy data from the [Canadian Government's Open Data portal](open.canada.ca).

There are several datasets provided on the portal that are either improperly formatted, or fragmented (e.g. the Consumer Price Index dataset links to only CPI data for Canada and Newfoundland instead of all 6 data sets that include data for all provinces and the federal level). These scripts will amalgamate data from all data sets where fragmentation is present, and clean the data.

## Cleaning
A lot of this is my interpretation of how the data should look. I'm very open to suggestions on how the data should end up.
- Comments and null rows are removed
- Variable names are made concise and are CapitalisedCamelCase
- The data set is skinny in that there is a row for every variable of every observation (example to follow)
- Columns are variables
- Rows correspond to one and only one observation
- Data is not summarised

Output format:

Region | Period              | variable           | value
-------|:--------------------|:-------------------|:-----
Can    | Nov2013             | HealthPersonalCare | 118
Can    | Oct2014             | HealthPersonalCare | 118.8
Can    | Nov2014             | HealthPersonalCare | 119.9
Can    | %Δ(Oct2014-Nov2014) | HealthPersonalCare | 0.9
Can    | %Δ(Nov2013-Nov2014) | HealthPersonalCare | 1.6
QC     | Nov2013             | PersonalCare       | 118.3
QC     | Oct2014             | PersonalCare       | 118.4
QC     | Nov2014             | PersonalCare       | 119.5
QC     | %Δ(Oct2014-Nov2014) | PersonalCare       | 0.9
QC     | %Δ(Nov2013-Nov2014) | PersonalCare       | 1

A description of variables for each data set will also be provided for ease of interpretation.
