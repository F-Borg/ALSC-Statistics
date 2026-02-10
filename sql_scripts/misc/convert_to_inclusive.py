import re
import fileinput
import sys
import shutil

# C:\Users\Fin\Documents\GitHub\ALSC-Statistics\sql_scripts\misc\batting_test.pgsql
# C:\Users\Fin\Documents\GitHub\ALSC-Statistics\sql_scripts\misc\helper.pgsql

shutil.copyfile("sql_scripts/misc/helper.pgsql","sql_scripts/misc/helper_i.pgsql")
shutil.copyfile("sql_scripts/alsc-history/batting.pgsql","sql_scripts/alsc-history/batting_i.pgsql")
shutil.copyfile("sql_scripts/alsc-history/bowling.pgsql","sql_scripts/alsc-history/bowling_i.pgsql")




for line in fileinput.input(files=["sql_scripts/misc/helper_i.pgsql","sql_scripts/alsc-history/batting_i.pgsql","sql_scripts/alsc-history/bowling_i.pgsql"], inplace=True):
    # sys.stdout.write ensures the modified line goes back to the file
    _z = sys.stdout.write(
        re.sub(r"\bz_",r"z_i_",
            re.sub(r"\b(batting|bowling|fielding|team)(_\d\d)",r"\1_i\2",
                re.sub(r"\b(batting|bowling|innings|matches|seasons|wickets)\b",r"\1_i",line,flags=re.IGNORECASE),flags=re.IGNORECASE),flags=re.IGNORECASE)
    )
fileinput.close()




for line in fileinput.input(files=['sql_scripts/misc/helper_i.pgsql'], inplace=True):
    # sys.stdout.write ensures the modified line goes back to the file
    _z = sys.stdout.write(
        re.sub(r"\bz_",r"z_i_",
            re.sub(r"\b(batting|bowling|fielding|team)(_\d\d)",r"\1_i\2",
                re.sub(r"\b(batting|bowling|innings|matches|seasons|wickets)\b",r"\1_i",line,flags=re.IGNORECASE),flags=re.IGNORECASE),flags=re.IGNORECASE)
    )



# tables
re.sub(r"\b(batting|bowling|innings|matches|seasons|wickets)\b",r"\1_i",line)
# views
re.sub(r"\b(batting|bowling|fielding|team)(_\d\d)",r"\1_i\2",line,flags=re.IGNORECASE)
re.sub(r"\bz_",r"z_i_","CREATE OR REPLACE VIEW batting_01_summary_ind AS")


