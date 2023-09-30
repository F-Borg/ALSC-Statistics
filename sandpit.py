from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()



season = pd.read_sql(con=pgconn, sql=f"select * from season_summary")





import re




str1 = """
SELECT Sum(IIf(Bowling_Figures_All!w>4,1,0)) AS 5WI, players!surname & ", " & players![first name] AS Name, Batting_Career_Summary.Mat, Bowling_Figures_All.PlayerID
FROM Batting_Career_Summary INNER JOIN (Players INNER JOIN Bowling_Figures_All ON Players.PlayerID = Bowling_Figures_All.PlayerID) ON Batting_Career_Summary.PlayerID = Players.PlayerID
GROUP BY players!surname & ", " & players![first name], Batting_Career_Summary.Mat, Bowling_Figures_All.PlayerID
ORDER BY Sum(IIf(Bowling_Figures_All!w>4,1,0)) DESC;
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
