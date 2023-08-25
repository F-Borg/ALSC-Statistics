from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT DISTINCTROW IIf(First(w_wickin!w)=10,"",First(w_wickin!w) & "/") & Sum(Bowling![No Balls])+Sum(Bowling!Wides)+Sum(Bowling![Runs off Bat])+First(Innings!Extras) AS Score, Sum(bowling!overs) & "." & Sum(bowling![extra balls]) AS [Overs Bowled], 6*(Sum(Bowling![No Balls])+Sum(Bowling!Wides)+Sum(Bowling![Runs off Bat])+First(Innings!Extras))/Sum(6*bowling!overs+bowling![extra balls]) AS [Run Rate], Matches.Opponent, Sum(Bowling![No Balls])+Sum(Bowling!Wides)+Sum(Bowling![Runs off Bat])+First(Innings!Extras) AS totala, Matches.MatchID, Innings.InningsNO
FROM Seasons INNER JOIN (Matches INNER JOIN ((Innings INNER JOIN w_wickin ON Innings.InningsID=w_wickin.InningsID) INNER JOIN Bowling ON Innings.InningsID=Bowling.InningsID) ON Matches.MatchID=Innings.MatchID) ON Seasons.SeasonID=Matches.SeasonID
GROUP BY Matches.Opponent, Innings.InningsID, Matches.MatchID, Innings.InningsNO
HAVING (((Innings.InningsNO)=1 Or (Innings.InningsNO)=2))
ORDER BY Sum(Bowling![No Balls])+Sum(Bowling!Wides)+Sum(Bowling![Runs off Bat])+First(Innings!Extras) DESC;"""

print(re.sub('\[([\w\s]+)\]','\\1',str1).
      replace('DISTINCTROW','').
      replace('& "." &',"||'.'||").
      replace('& "/"',"||'/'").
      replace('First(','max(').
      replace('extra balls','extra_balls').
      replace('how out','how_out').
      replace('No Balls','no_balls').
      replace('Runs off Bat','runs_off_bat').
      replace('!','.').
      replace('IIf(','(CASE WHEN ')
)
