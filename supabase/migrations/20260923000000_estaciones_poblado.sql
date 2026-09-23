alter table estaciones
    add column poblado boolean not null default false;

update estaciones
set poblado = true
where id in (
    '00000000-0000-4000-8000-000000000101',
    '00000000-0000-4000-8000-000000000102',
    '00000000-0000-4000-8000-000000000103',
    '00000000-0000-4000-8000-000000000104'
);

update configuracion
set version = 7;