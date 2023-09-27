from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT Batting_Partnerships_All.Wicket, Max(Batting_Partnerships_All.p) AS MaxOfp, Seasons.Eleven
FROM Seasons INNER JOIN (Matches INNER JOIN (Players AS Players_1 INNER JOIN (Players INNER JOIN (Batting_Partnerships_All INNER JOIN Innings ON Batting_Partnerships_All.InningsID = Innings.InningsID) ON Players.PlayerID = Batting_Partnerships_All.PlayerID) ON Players_1.PlayerID = Batting_Partnerships_All.[Not Out Batsman]) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY Batting_Partnerships_All.Wicket, Seasons.Eleven
HAVING (((Seasons.Eleven)="3rd"))
ORDER BY Batting_Partnerships_All.Wicket, Max(Batting_Partnerships_All.p) DESC;
"""

print(re.sub('\[([\w\s]+)\]','\\1',str1).
      replace('DISTINCTROW','').
      replace('& "." &',"||'.'||").
      replace('& ", " &',"||', '||").
      replace('& "/"',"||'/'").
      replace(',1,0',' then 1 else 0 end').
      replace('First(','max(').
      replace('extra balls','extra_balls').
      replace('how out','how_out').
      replace('No Balls','no_balls').
      replace('Runs off Bat','runs_off_bat').
      replace('first name','firstname').
      replace('date of birth','dob').
      replace('Batting_Career_Summary','batting_01_summary_ind').
      replace('!','.').
      replace('IIf(','(CASE WHEN ')
)
