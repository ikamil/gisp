--- Создание и заполнение основных справочников

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

create table tbranch (id serial primary key, name text
    , created timestamp default now(), creator_id bigint constraint fk_okpd_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_okpd_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_okpd_deleter references auth_user);

insert into tbranch (name) select distinct regexp_split_to_table(appliance_id,', ')from tsupport;

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


--- Формирование промежуточных статистических и справочных данных

create table nonfinancesup (id int, name text, ogrn bigint, okpd2 text);

copy nonfinancesup from '/var/imp/nonfinancesup.csv' with (delimiter ',', format csv, header);

copy nonfinancesup from 'C:\cloud\dev\PycharmProjects\hakaton\gisp\data\imp\nonfinancesup.csv' with (delimiter ',', format csv, header);

drop table branchokpd;

create table branchokpd (dept text, branch text, okved text, okved_name text, okpd text, okpd_name text);

copy branchokpd from '/var/imp/branchokpd.csv' with (delimiter ';', format csv, header);

select * from branchokpd left join tbranch on name=branch;

drop table registry;

create table registry (ogrn text, okpd2 text, num int);

create table ogrnokpd719  (ogrn text, okpd2 text);

copy ogrnokpd719 from '/var/imp/ogrnokpd719.csv' with (delimiter ';', format csv, header);

create table ogrnokpd878  (ogrn text, okpd2 text);

copy ogrnokpd878 from '/var/imp/ogrnokpd878.csv' with (delimiter ';', format csv, header);

insert into registry (ogrn, okpd2, num) select ogrn, okpd2, 719 from ogrnokpd719;

insert into registry (ogrn, okpd2, num) select ogrn, okpd2, 878 from ogrnokpd878;

alter table registry alter column ogrn type bigint using regexp_replace(ogrn,'[^0-9]','','g')::bigint;

select * from registry r, branchokpd o, tcompany c, tbranch b where c.ogrn=r.ogrn and r.okpd2=o.okpd and o.branch=b.name;

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


--- Создание и заполнение JSON таблиц (часть данных обрабатывается в локальном Postgres, поэтому путь файла не Unix

drop table allocators;

create table allocators (dta text);

copy allocators from 'C:\temp\hack2021\folder\allocators.json';

alter table allocators add column js jsonb;

select * from allocators where dta like '% "СРЕДНЯЯ%';

update allocators set js= regexp_replace(dta, ' "([А-Я0-9№ ]+)""', '\1"', 'g')::jsonb where dta not like '%"""%';

select * from allocators where dta not like '%"""%' and dta like '%СПОРТИВНАЯ%';

drop table receivers;

create table receivers (dta text);

copy receivers from 'C:\temp\hack2021\folder\receivers.json';

select * from receivers;

alter table receivers add column js jsonb;

update receivers set js=dta::jsonb where dta not like '%""%';

select * from receivers where dta like '%КОМПЛЕКСНЫЙ%';

drop table subs;

create table subs (dta text);

copy subs from 'C:\temp\hack2021\folder\subs_dump_1.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_1_16.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_2.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_2_8.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_3.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_3_4.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_4.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_4_11.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_5.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_5_14.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_6.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_6_6.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_7.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_7_3.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_8.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_8_10.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_9.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_9_17.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_12.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_13.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_15.json';
copy subs from 'C:\temp\hack2021\folder\subs_dump_18.json';

alter table subs add js jsonb;


-- Очистка JSON таблиц от невалидных элементов

create table subs2 (js jsonb );

create table allocators2 (js jsonb );

create table  receivers2(js jsonb );

do $$
declare  cc text;
begin
  for cc in select dta from subs loop
      begin
        insert into subs2(js) values (regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(cc,
    E'[\\n\\r]+', ' ', 'g' )
    , ' ""([^"]+)"""', '\1"', 'gi')
    , '": "([а-я ё]+)"([а-я ё]+)"([а-я ё]+)""', '": "\1 \2 \3"', 'gi')
    , '([^:"]) ""([^"]+)""', '\1 \2', 'gi')
    , ': ""([^"]+)""', ': "\1"', 'gi')
    , ' "([^"]+)""', ' \1"', 'gi')
    , '"корпорация "мсп"', 'Корпорация МСП', 'gi')
    , 'закон "о федеральном бюджете', 'закон О федеральном бюджете', 'gi')
    , ' "([^"]+)" ', ' \1 ', 'gi')
    , '"(налог на профессиональный доход|мой бизнес|российский экспортный центр|ргсу|сетелем банк|ВЯТСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ)"', '\1', 'gi')
    , '"ФГАОУ ВО "([а-я0-9 .-]+)"([^"])', '"ФГАОУ ВО \1\2', 'gi')
    , '": ""([а-я]+)', '": "\1', 'gi')
    , '([а-я]+)""', '\1"', 'gi')
    ::jsonb);
      exception when others then null;
      end;
  end loop;
end;
$$;


do $$
declare  cc text;
begin
  for cc in select dta from allocators loop
      begin
        insert into allocators2(js) values (regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(cc,
    E'[\\n\\r]+', ' ', 'g' )
    , ' ""([^"]+)"""', '\1"', 'gi')
    , '": "([а-я ё]+)"([а-я ё]+)"([а-я ё]+)""', '": "\1 \2 \3"', 'gi')
    , '([^:"]) ""([^"]+)""', '\1 \2', 'gi')
    , ': ""([^"]+)""', ': "\1"', 'gi')
    , ' "([^"]+)""', ' \1"', 'gi')
    , '"корпорация "мсп"', 'Корпорация МСП', 'gi')
    , 'закон "о федеральном бюджете', 'закон О федеральном бюджете', 'gi')
    , ' "([^"]+)" ', ' \1 ', 'gi')
    , '"(налог на профессиональный доход|мой бизнес|российский экспортный центр|ргсу|сетелем банк|ВЯТСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ)"', '\1', 'gi')
    , '"ФГАОУ ВО "([а-я0-9 .-]+)"([^"])', '"ФГАОУ ВО \1\2', 'gi')
    , '": ""([а-я]+)', '": "\1', 'gi')
    , '([а-я]+)""', '\1"', 'gi')
    ::jsonb);
      exception when others then null;
      end;
  end loop;
end;
$$;

do $$
declare  cc text;
begin
  for cc in select dta from receivers loop
      begin
        insert into receivers2(js) values (regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(
            regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(cc,
    E'[\\n\\r]+', ' ', 'g' )
    , ' ""([^"]+)"""', '\1"', 'gi')
    , '": "([а-я ё]+)"([а-я ё]+)"([а-я ё]+)""', '": "\1 \2 \3"', 'gi')
    , '([^:"]) ""([^"]+)""', '\1 \2', 'gi')
    , ': ""([^"]+)""', ': "\1"', 'gi')
    , ' "([^"]+)""', ' \1"', 'gi')
    , '"корпорация "мсп"', 'Корпорация МСП', 'gi')
    , 'закон "о федеральном бюджете', 'закон О федеральном бюджете', 'gi')
    , ' "([^"]+)" ', ' \1 ', 'gi')
    , '"(налог на профессиональный доход|мой бизнес|российский экспортный центр|ргсу|сетелем банк|ВЯТСКИЙ ГОСУДАРСТВЕННЫЙ УНИВЕРСИТЕТ)"', '\1', 'gi')
    , '"ФГАОУ ВО "([а-я0-9 .-]+)"([^"])', '"ФГАОУ ВО \1\2', 'gi')
    , '": ""([а-я]+)', '": "\1', 'gi')
    , '([а-я]+)""', '\1"', 'gi')
    ::jsonb);
      exception when others then null;
      end;
  end loop;
end;
$$;

select jsonb_extract_path_text(js, 'info','sum') from subs2;



--- Вычисление Рейтинговых показателей

create table ogrnstat as
select js->'receiver'->0->'ogrn' , count(e.value)
from subs2, jsonb_array_elements(js->'marks') e where js->'marks'->0 is not null and jsonb_extract_path_text(e.value,'value')<>'0'
    group by 1;

copy ogrnstat to 'C:\cloud\dev\PycharmProjects\hakaton\gisp\data\imp\ogrnstat.csv';

drop table ogrnstat;

create table ogrnstat(ogrn text, cnt text);

copy ogrnstat from '/var/imp/ogrnstat.csv';

select * from ogrnstat;

delete from ogrnstat where ogrn = '""';

alter table ogrnstat alter column ogrn type bigint using regexp_replace(ogrn,'[^0-9]','','g')::bigint;

alter table ogrnstat alter column cnt type int using regexp_replace(cnt,'[^0-9]','','g')::int;

insert into tokpd (name) select distinct okved from branchokpd where okved not in (select name from tokpd);

create table tbranchstat (id serial primary key,
branch_id bigint constraint fk_bstat_branch references tbranch,
okpd2_id bigint constraint fk_bstat_okpd references tokpd,
region_id bigint constraint fk_bstat_region references tregion,
rate int
    , created timestamp default now(), creator_id bigint constraint fk_city_creator references auth_user
    , modified timestamp default now(), modifier_id bigint constraint fk_city_modifier references auth_user
    , deleted timestamp, deleter_id bigint constraint fk_city_deleter references auth_user
);

insert into tbranchstat(okpd2_id, region_id, branch_id, rate)
select d.id, c.region_id, b.id, count(1)
from registry r, branchokpd o, tcompany c, tbranch b, ogrnstat s , tokpd d
where s.ogrn=c.ogrn and c.ogrn=r.ogrn and r.okpd2=o.okpd and o.branch=b.name and d.name=o.okved group by 1,2,3;

alter table tsupport add column okved1_rate int, add column okved2_rate int, add column okved3_rate int;

alter table tsupport add column total_rate int;


--- Заполнение вычисленных показателей в список Мер поддержки

with sup as (select id, region_id, unnest(string_to_array(appliance_id,', ')) branch from tsupport),
dta as (select u.id, dense_rank() over (partition by u.id order by rate desc) rnk, s.rate,  sum(s.rate) over (partition by u.id) sm
       from sup u, tbranch b, tbranchstat s where b.name=u.branch and u.region_id=s.region_id and b.id=s.branch_id),
upd as (select d.id, min(d.sm) as sm, min(case when d.rnk=1 then d.rate end) r1,
        min(case when d.rnk=2 then d.rate end) r2, min(case when d.rnk=3 then d.rate end) r3 from dta d group by 1)
update tsupport t set okved1_rate=u.r1, okved2_rate=u.r2, okved3_rate=u.r3, total_rate=u.sm from upd u where u.id=t.id ;

update tsupport set total_rate=0 where total_rate isnull;

select * from tbranchstat;

select count (distinct s.ogrn) from ogrnstat s, tcompany c where s.ogrn=c.ogrn;
