


CREATE OR REPLACE VIEW bowling_01_summary_ind AS
SELECT bcsa.Name, bcsa.Mat, bcsa.O, bcsa.Balls, bcsa.Mdns, bcsa.Total Runs, bcsa.Total Wickets, bcsa.Average, bcsa.Strike Rate, bcsa.RPO, bcsa.ABD, bcsa.4s, bcsa.6s, bcsa.Figures, bcsa.5WI, bcsa.Expensive Over, bcsa.Catches, 
bcsa.Stumpings, bcsa.PlayerID
FROM bcsa
WHERE (((bcsa.Balls)>0)) OR (((bcsa.Dismissals)>0))
GROUP BY bcsa.Name, bcsa.Mat, bcsa.O, bcsa.Balls, bcsa.Mdns, bcsa.Total Runs, bcsa.Total Wickets, bcsa.Average, bcsa.Strike Rate, bcsa.RPO, bcsa.ABD, bcsa.4s, bcsa.6s, bcsa.Figures, bcsa.5WI, bcsa.Expensive Over, bcsa.Catches, bcsa.Stumpings, bcsa.PlayerID;

CREATE OR REPLACE VIEW bowling_02_p1_wickets AS
CREATE OR REPLACE VIEW bowling_03_p1_ave AS
CREATE OR REPLACE VIEW bowling_04_p1_sr AS
CREATE OR REPLACE VIEW bowling_05_p2_career_econ_low AS
CREATE OR REPLACE VIEW bowling_06_p2_career_econ_high AS
CREATE OR REPLACE VIEW bowling_07_p2_5WI AS
CREATE OR REPLACE VIEW bowling_08_p2_season_wickets AS
CREATE OR REPLACE VIEW bowling_09_p3_best_figs AS
CREATE OR REPLACE VIEW bowling_10_p3_hat_trick AS
CREATE OR REPLACE VIEW bowling_11_p3_10WM AS
CREATE OR REPLACE VIEW bowling_12_p3_match_econ AS
CREATE OR REPLACE VIEW bowling_13_p4_match_runs AS
CREATE OR REPLACE VIEW bowling_14_p4_match_econ_high AS
CREATE OR REPLACE VIEW bowling_15_p4_expensive_over AS
CREATE OR REPLACE VIEW bowling_16_p4_extras_high AS
CREATE OR REPLACE VIEW bowling_17_dismissals_ct AS
CREATE OR REPLACE VIEW bowling_18_dismissals_b AS
CREATE OR REPLACE VIEW bowling_19_dismissals_lbw AS
CREATE OR REPLACE VIEW bowling_20_dismissals_no_lbw AS
CREATE OR REPLACE VIEW bowling_21_dismissals_st AS




