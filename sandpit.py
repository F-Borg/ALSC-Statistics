from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT Players!surname & ", " & players![first name] AS Name, w_player_season_matches.Mat, Sum(IIf(wickets![how out]="caught",1,0)) AS Catches, Sum(IIf(wickets![how out]="stumped",1,0)) AS Stumpings, Sum(IIf(wickets![how out]="run out",1,0)) AS [Run Outs]
FROM Matches INNER JOIN (Innings INNER JOIN (Seasons INNER JOIN ((Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) INNER JOIN w_player_season_matches ON Players.PlayerID = w_player_season_matches.PlayerID) ON Seasons.SeasonID = w_player_season_matches.SeasonID) ON Innings.InningsID = Wickets.InningsID) ON (Seasons.SeasonID = Matches.SeasonID) AND (Matches.MatchID = Innings.MatchID)
GROUP BY Players!surname & ", " & players![first name], w_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Matches.SeasonID, w_player_season_matches.Mat
HAVING (((Matches.SeasonID)=[Enter Season ID]))
ORDER BY Sum(IIf(wickets![how out]="caught",1,0)) DESC , Sum(IIf(wickets![how out]="stumped",1,0)) DESC , Sum(IIf(wickets![how out]="run out",1,0)) DESC , w_player_season_matches.Mat DESC;

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
