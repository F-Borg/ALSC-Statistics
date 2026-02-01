import re
import fileinput
import sys

# C:\Users\Fin\Documents\GitHub\ALSC-Statistics\sql_scripts\misc\batting_test.pgsql


for line in fileinput.input(files=['sql_scripts/misc/batting_test.pgsql'], inplace=True):
    # sys.stdout.write ensures the modified line goes back to the file
    sys.stdout.write(re.sub(r"\b(batting|bowling|innings|matches|seasons|wickets)\b",r"\1_i",line))


# tables
re.sub(r"\b(batting|bowling|innings|matches|seasons|wickets)\b",r"\1_i",line)
# views
re.sub(r"\b(batting|bowling|fielding|team)(_\d\d)",r"\1_i\2","CREATE OR REPLACE VIEW batting_01_summary_ind AS")
re.sub(r"\bz_",r"_i","CREATE OR REPLACE VIEW batting_01_summary_ind AS")


