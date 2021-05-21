create table tregion (id serial primary key , name varchar(200), image varchar(500), description text
    , created timestamp default now(), creator_id bigint constraint fk_region_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_region_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_region_deleter references auth_user);

insert into tregion (name) select distinct region from tsupport where region is not null order by region;

create table tsupport (id serial primary key,
    url text,
    small_name text,
    full_name text,
    number_npa text,
    date_npa date,
    npa_name text,
    description text,
    purpose text,
    objective text,
    type_mera text,
    type_format_support text,
    srok_vozvrata text,
    procent_vozvrata text,
    guarante_periode text,
    guarantee_cost text,
    appliance_id text,
    okved2 text,
    complexity text,
    amount_of_support text,
    regularity_select text,
    period text,
    dogovor boolean,
    gos_program text,
    event text,
    dop_info text,
    is_not_active boolean,
    prichina_not_act text,
    req_zayavitel text,
    request_project text,
    is_sofinance text,
    dolya_isofinance text,
    budget_project text,
    pokazatel_result text,
    territorial_level text,
    region_id bigint constraint fk_city_region references tregion not null,
    respons_structure text,
    org_id text
    , created timestamp default now(), creator_id bigint constraint fk_city_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_city_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_city_deleter references auth_user);

update tsupport s set region_id=r.id from tregion r where r.name=s.region;