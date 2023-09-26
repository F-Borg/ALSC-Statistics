-- Add new player
-- insert into players values (469,'Sharrad, Lachlan','Lachlan','Sharrad',NULL,'Lachlan Sharrad');

-- Update player name
update players set 
    player_name = 'Waldhuter, Joshua'
    , name_fl = 'Joshua Waldhuter'
    , firstname = 'Joshua'
where playerid = 265
;


select * from players where playerid = 265



-- drop view z_All_Player_Dates cascade

