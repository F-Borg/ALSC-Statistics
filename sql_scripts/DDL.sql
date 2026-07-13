--DDL

CREATE TABLE IF NOT EXISTS public.batting
(
    inningsid bigint,
    playerid bigint,
    batting_position double precision,
    how_out text COLLATE pg_catalog."default",
    bowler_name text COLLATE pg_catalog."default",
    score double precision,
    _4s bigint,
    _6s bigint,
    balls_faced double precision,
    fow double precision,
    wicket double precision,
    not_out_batter double precision
)
;

CREATE TABLE IF NOT EXISTS public.bowling
(
    inningsid bigint,
    playerid bigint,
    overs bigint,
    extra_balls bigint,
    maidens bigint,
    wides bigint,
    no_balls bigint,
    runs_off_bat bigint,
    _4s_against bigint,
    _6s_against bigint,
    highover bigint,
    _2nd_high_over double precision,
    _3rd_high_over double precision
)
;

CREATE TABLE IF NOT EXISTS public.innings
(
    inningsid bigint,
    extras bigint,
    matchid bigint,
    inningsno bigint,
    innings_type text COLLATE pg_catalog."default",
    bat_overs double precision,
    extra_balls double precision
)
;

CREATE TABLE IF NOT EXISTS public.matches
(
    matchid bigint,
    opponent text COLLATE pg_catalog."default",
    ground text COLLATE pg_catalog."default",
    round text COLLATE pg_catalog."default",
    seasonid bigint,
    result text COLLATE pg_catalog."default",
    date1 timestamp without time zone,
    date2 timestamp without time zone,
    nodays bigint,
    captain double precision,
    wicketkeeper double precision,
    fv_1st double precision,
    fv_2nd double precision
)
;

CREATE TABLE IF NOT EXISTS public.players
(
    playerid bigint,
    player_name text COLLATE pg_catalog."default",
    firstname text COLLATE pg_catalog."default",
    surname text COLLATE pg_catalog."default",
    dob timestamp without time zone,
    name_fl character varying COLLATE pg_catalog."default"
)
;

CREATE TABLE IF NOT EXISTS public.seasons
(
    seasonid bigint,
    year text COLLATE pg_catalog."default",
    association text COLLATE pg_catalog."default",
    grade text COLLATE pg_catalog."default",
    eleven text COLLATE pg_catalog."default",
    captain bigint,
    vice_captain bigint,
    posn bigint,
    nbw_status text COLLATE pg_catalog."default",
    playhq_season text COLLATE pg_catalog."default"
)
;

CREATE TABLE IF NOT EXISTS public.wickets
(
    inningsid bigint,
    batting_position bigint,
    batter_name text COLLATE pg_catalog."default",
    how_out text COLLATE pg_catalog."default",
    assist double precision,
    playerid double precision,
    hat_trick bigint
)
;