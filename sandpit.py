from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT players!surname & ", " & players![first name] AS Name, Seasons.Eleven, Matches.Round, Matches.Opponent, batting!score & IIf(batting![how out]="not out" Or batting![how out]="retired hurt" Or batting![how out]="forced retirement","*","") AS Score, Batting.[Balls Faced], Batting.[4s], Batting.[6s], Batting.[Batting Position]
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON Innings.InningsID = Batting.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE (((Seasons.SeasonID)=73 Or (Seasons.SeasonID)=74 Or (Seasons.SeasonID)=75))
GROUP BY players!surname & ", " & players![first name], Seasons.Eleven, Matches.Round, Matches.Opponent, batting!score & IIf(batting![how out]="not out" Or batting![how out]="retired hurt" Or batting![how out]="forced retirement","*",""), Batting.[Balls Faced], Batting.[4s], Batting.[6s], Batting.[Batting Position], Seasons.Grade, Seasons.Year, Seasons.Grade, Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round, Batting.Score, Players.PlayerID
HAVING (((Batting.[Balls Faced]) Is Not Null))
ORDER BY players!surname & ", " & players![first name], Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round, Batting.[Balls Faced] DESC , Batting.Score DESC , batting!score & IIf(batting![how out]="not out" Or batting![how out]="retired hurt" Or batting![how out]="forced retirement","*","") DESC;


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
