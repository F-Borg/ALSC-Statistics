from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT Players!surname & ", " & players![first name] AS Name, 100*batting!score/batting![balls faced] AS [Strike Rate], batting!score & IIf(batting![how out]="not out" Or batting![how out]="retired hurt" Or batting![how out]="forced retirement","*","") AS Runs, Batting.[Balls Faced], Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON Innings.InningsID = Batting.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY Players!surname & ", " & players![first name], 100*batting!score/batting![balls faced], batting!score & IIf(batting![how out]="not out" Or batting![how out]="retired hurt" Or batting![how out]="forced retirement","*",""), Batting.[Balls Faced], Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association, Batting.Score
HAVING (((Batting.Score)>29))
ORDER BY 100*batting!score/batting![balls faced] DESC;


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
