


select * from z_bowling_totals
where matchid = 37


-- drop table batting cascade;
-- drop table bowling cascade;
-- drop table seasons cascade;
-- drop table innings cascade;


select * from seasons where seasonid = 76;
select * from matches where seasonid = 76;
select * from innings where matchid = 778;
select * from bowling where inningsid = 1743;
select * from wickets where inningsid = 1743;
select * from batting where inningsid = 1742;


