-- Add new player
-- insert into players values (469,'Sharrad, Lachlan','Lachlan','Sharrad',NULL,'Lachlan Sharrad');

-- Update player name
update players set 
    player_name = 'Waldhuter, Joshua'
    , name_fl = 'Joshua Waldhuter'
    , firstname = 'Joshua'
where playerid = 265
;

update players set 
    player_name = 'Negruk, Michael'
    , name_fl = 'Michael Negruk'
    , firstname = 'Michael'
where playerid = 447
;




select * from players where playerid = 447

select * from players where surname = 'Fleming'

-- drop view z_All_Player_Dates cascade

