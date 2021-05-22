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

create table tcompany(id serial primary key,
full_name text,
email text,
platforms text,
okved2 text,
enterprise_type text,
main_activity text,
additional_activity text,
legal_form text,
company_type text,
company_status text,
reg_date text,
tax_code text,
real_address text,
attributes text,
name text,
organization_type text,
industry text,
ogrn text,
inn text,
checkpoint text,
region_id bigint constraint fk_city_region references tregion not null,
address text,
contact_email text,
website text,
contact_number text
    , created timestamp default now(), creator_id bigint constraint fk_city_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_city_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_city_deleter references auth_user
                     ,region text
);

insert into tregion (name) select distinct trim(split_part(region,'[',1)) from tcompany s where region is not null and not exists
    (select 1 from tregion r where r.name=trim(split_part(s.region,'[',1)));

update tcompany s set region_id=r.id from tregion r where r.name=trim(split_part(s.region,'[',1));

select distinct region from tcompany where region_id is null and region is not null ;

create table nonfinancesup (id int, name text, ogrn bigint, okpd2 text);

copy nonfinancesup from '/var/imp/nonfinancesup.csv' with (delimiter ',', format csv, header);

copy nonfinancesup from 'C:\cloud\dev\PycharmProjects\hakaton\gisp\data\imp\nonfinancesup.csv' with (delimiter ',', format csv, header);

select * from nonfinancesup;

drop table tokpd2;

create table tokpd (id serial primary key, name text
    , created timestamp default now(), creator_id bigint constraint fk_okpd_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_okpd_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_okpd_deleter references auth_user
);

insert into tokpd (name) select distinct okpd2 from nonfinancesup where nullif(trim(okpd2),'') is  not  null order by 1;

select name, trim(regexp_replace(regexp_replace(lower(name), '[^а-я ]+', '', 'g'), ' +', ' ', 'g')) from nonfinancesup;

select array_to_string(tsvector_to_array(to_tsvector('russian', trim(regexp_replace(regexp_replace(lower(name), '[^а-я ]+', '', 'g'), ' +', ' ', 'g')))),' ')
from nonfinancesup;

select count(distinct name),
       count (distinct array_to_string(tsvector_to_array(to_tsvector('russian', trim(regexp_replace(regexp_replace(lower(name), '[^а-я ]+', '', 'g'), ' +', ' ', 'g')))),' ')) from nonfinancesup;

create table tdict (id serial primary key, name text
    , created timestamp default now(), creator_id bigint constraint fk_okpd_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_okpd_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_okpd_deleter references auth_user
);

insert into tdict (name) select distinct array_to_string(tsvector_to_array(to_tsvector('russian', trim(regexp_replace(regexp_replace(lower(name), '[^а-я ]+', '', 'g'), ' +', ' ', 'g')))),' ') from nonfinancesup;

alter table nonfinancesup add dict text;

update nonfinancesup set dict=array_to_string(tsvector_to_array(to_tsvector('russian', trim(regexp_replace(regexp_replace(lower(name), '[^а-я ]+', '', 'g'), ' +', ' ', 'g')))),' ')
where name is not null;

drop table tnonfinancesup;

create table tnonfinancesup(id serial primary key,
company_id bigint constraint fk_nonfin_company references tcompany,
okpd2_id bigint constraint fk_nonfin_okpd references tokpd not null,
dict_id bigint constraint fk_nonfin_dict references tdict,
name text
    , created timestamp default now(), creator_id bigint constraint fk_city_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_city_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_city_deleter references auth_user
);

update tcompany set ogrn=regexp_replace(ogrn, '[^0-9]','','g') where not ogrn ~ '^[0-9]+$';

select * from tcompany where not ogrn ~ '^[0-9]+$';

alter table tcompany alter column ogrn type bigint using ogrn::bigint;

insert into tnonfinancesup (id, company_id, okpd2_id, dict_id, name)
select s.id, c.id company_id, o.id okpd2_id, d.id dict_id, s.name from nonfinancesup s inner join tcompany c on s.ogrn=c.ogrn
    inner join tokpd o on o.name=s.okpd2
    inner join tdict d on d.name=s.dict;

select count(1) from tnonfinancesup;