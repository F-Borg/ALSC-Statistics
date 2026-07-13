# Claude Assistance

This system is used to create a cricket stats book for my club. It scrapes scorecards from the PlayHQ website and outputs them into markdown, then I manually edit the markdown files to fill in any gaps, then I run a function to upload the markdown files into a postgres database.

## Module 1: Data Load

The important scripts are:

- main.py: calls the other functions. It is run manually so that I can stop and check/modify the output after each scorecard is scraped.
- scrape_scorecard.py: contains the scrape_scorecard function that scrapes a given PlayHQ web page and outputs into markdown files.
- wrangle_match_data.py: contains the wrangle_match_data function that performs data transformations and then loads the data into postgres.
- DDL.sql: contains the DDLs of the postgres tables.

## Module 2: Output Stats

The important scripts are:

- batting.pgsql, bowling.pgsql, fielding.pgsql, team.pgsql, yb_all.pgsql: contain the views that calculate the various stats.
- output_to_excel.py and yearbook_to_excel.py: write the formatted output of the views to Excel.
