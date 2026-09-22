create table tipos_vehiculo (
    id uuid primary key default gen_random_uuid(),
    codigo text not null unique
        check (codigo in ('bus', 'microbus', 'taxi', 'car', 'van')),
    nombre text not null,
    activo boolean default true,
    creado_en timestamptz default now()
);

create table vehiculos (
    id uuid primary key default gen_random_uuid(),
    nombre text,
    placa text unique,
    tipo_vehiculo_id uuid not null
        references tipos_vehiculo(id),
    tipo_transporte text not null
        check (tipo_transporte in ('public', 'private')),
    capacidad integer,
    activo boolean default true,
    creado_en timestamptz default now()
);

create table rutas (
    id uuid primary key default gen_random_uuid(),
    nombre text not null,
    origen_nombre text not null,
    destino_nombre text not null,
    origen_lat double precision not null,
    origen_lng double precision not null,
    destino_lat double precision not null,
    destino_lng double precision not null,
    activo boolean default true,
    creado_en timestamptz default now()
);

create table vehiculo_rutas (
    id uuid primary key default gen_random_uuid(),
    vehiculo_id uuid not null
        references vehiculos(id)
        on delete cascade,
    ruta_id uuid not null
        references rutas(id)
        on delete cascade,
    activo boolean default true,
    creado_en timestamptz default now(),
    unique (vehiculo_id, ruta_id)
);

create table estaciones (
    id uuid primary key default gen_random_uuid(),
    nombre text not null,
    latitud double precision not null,
    longitud double precision not null,
    activo boolean default true,
    creado_en timestamptz default now()
);

create table ruta_estaciones (
    id uuid primary key default gen_random_uuid(),
    ruta_id uuid not null
        references rutas(id)
        on delete cascade,
    estacion_id uuid not null
        references estaciones(id)
        on delete cascade,
    orden_parada integer not null,
    unique (ruta_id, estacion_id),
    unique (ruta_id, orden_parada)
);

create table tarifas (
    id uuid primary key default gen_random_uuid(),
    ruta_id uuid not null
        references rutas(id)
        on delete cascade,
    tipo_vehiculo_id uuid not null
        references tipos_vehiculo(id),
    monto numeric(10, 2) not null,
    moneda text default 'NIO',
    vigente_desde timestamptz not null default now(),
    vigente_hasta timestamptz,
    activo boolean default true,
    creado_en timestamptz default now(),
    unique (ruta_id, tipo_vehiculo_id, vigente_desde)
);

create table configuracion (
    id integer primary key default 1 check (id = 1),
    version integer not null default 1,
    actualizado_en timestamptz default now()
);

create table reservas (
    id uuid primary key default gen_random_uuid(),
    origen text not null,
    destino text not null,
    fecha_salida text not null,
    hora_recogida text not null,
    estado text not null default 'Pending',
    monto_cotizacion numeric(10, 2) not null default 0,
    estado_sync text not null default 'pending',
    creado_en timestamptz default now()
);

create or replace function cerrar_tarifa_anterior()
returns trigger
language plpgsql
as $$
begin
    update tarifas
    set vigente_hasta = new.vigente_desde
    where ruta_id = new.ruta_id
      and tipo_vehiculo_id = new.tipo_vehiculo_id
      and id <> new.id
      and vigente_hasta is null
      and vigente_desde <= new.vigente_desde;
    return new;
end;
$$;

create trigger trg_cerrar_tarifa_anterior
after insert on tarifas
for each row
execute function cerrar_tarifa_anterior();

create or replace function tocar_configuracion()
returns trigger
language plpgsql
as $$
begin
    new.actualizado_en = now();
    return new;
end;
$$;

create trigger trg_tocar_configuracion
before update on configuracion
for each row
execute function tocar_configuracion();

alter table tipos_vehiculo enable row level security;
alter table vehiculos enable row level security;
alter table rutas enable row level security;
alter table vehiculo_rutas enable row level security;
alter table estaciones enable row level security;
alter table ruta_estaciones enable row level security;
alter table tarifas enable row level security;
alter table configuracion enable row level security;
alter table reservas enable row level security;

create policy lectura_tipos_vehiculo on tipos_vehiculo for select using (true);
create policy lectura_vehiculos on vehiculos for select using (true);
create policy lectura_rutas on rutas for select using (true);
create policy lectura_vehiculo_rutas on vehiculo_rutas for select using (true);
create policy lectura_estaciones on estaciones for select using (true);
create policy lectura_ruta_estaciones on ruta_estaciones for select using (true);
create policy lectura_tarifas on tarifas for select using (true);
create policy lectura_configuracion on configuracion for select using (true);
create policy lectura_reservas on reservas for select using (true);
create policy insertar_reservas on reservas for insert with check (true);

insert into tipos_vehiculo (id, codigo, nombre) values
    ('00000000-0000-4000-8000-000000000001', 'bus', 'Autobús'),
    ('00000000-0000-4000-8000-000000000002', 'microbus', 'Microbús'),
    ('00000000-0000-4000-8000-000000000003', 'taxi', 'Taxi'),
    ('00000000-0000-4000-8000-000000000004', 'car', 'Auto'),
    ('00000000-0000-4000-8000-000000000005', 'van', 'Van');

insert into estaciones (id, nombre, latitud, longitud) values
    ('00000000-0000-4000-8000-000000000101', 'Terminal de Buses de Somoto', 13.48858, -86.58185),
    ('00000000-0000-4000-8000-000000000102', 'Terminal COTRAN Sur (Estelí)', 13.07620, -86.35200),
    ('00000000-0000-4000-8000-000000000103', 'Terminal de Buses de Ocotal', 13.62220, -86.47670),
    ('00000000-0000-4000-8000-000000000104', 'Terminal El Mayoreo (Managua)', 12.13422, -86.19338);

insert into rutas (
    id, nombre, origen_nombre, destino_nombre,
    origen_lat, origen_lng, destino_lat, destino_lng
) values
    (
        '00000000-0000-4000-8000-000000000201',
        'Somoto - Estelí',
        'Somoto', 'Estelí',
        13.48858, -86.58185, 13.07620, -86.35200
    ),
    (
        '00000000-0000-4000-8000-000000000202',
        'Estelí - Managua',
        'Estelí', 'Managua',
        13.07620, -86.35200, 12.13422, -86.19338
    ),
    (
        '00000000-0000-4000-8000-000000000203',
        'Ocotal - Managua',
        'Ocotal', 'Managua',
        13.62220, -86.47670, 12.13422, -86.19338
    ),
    (
        '00000000-0000-4000-8000-000000000204',
        'Somoto - Managua',
        'Somoto', 'Managua',
        13.48858, -86.58185, 12.13422, -86.19338
    );

insert into vehiculos (id, nombre, placa, tipo_vehiculo_id, tipo_transporte, capacidad, activo) values
    (
        '00000000-0000-4000-8000-000000000301',
        'Unidad 42', '42',
        '00000000-0000-4000-8000-000000000001',
        'public', 18, true
    ),
    (
        '00000000-0000-4000-8000-000000000302',
        'Unidad 15', '15',
        '00000000-0000-4000-8000-000000000001',
        'public', 44, false
    ),
    (
        '00000000-0000-4000-8000-000000000303',
        'Unidad 88', '88',
        '00000000-0000-4000-8000-000000000001',
        'public', 21, true
    ),
    (
        '00000000-0000-4000-8000-000000000304',
        'Van ejecutiva', 'VAN-01',
        '00000000-0000-4000-8000-000000000005',
        'private', 12, true
    );

insert into vehiculo_rutas (vehiculo_id, ruta_id) values
    ('00000000-0000-4000-8000-000000000301', '00000000-0000-4000-8000-000000000201'),
    ('00000000-0000-4000-8000-000000000301', '00000000-0000-4000-8000-000000000204'),
    ('00000000-0000-4000-8000-000000000302', '00000000-0000-4000-8000-000000000202'),
    ('00000000-0000-4000-8000-000000000303', '00000000-0000-4000-8000-000000000203'),
    ('00000000-0000-4000-8000-000000000304', '00000000-0000-4000-8000-000000000204');

insert into ruta_estaciones (ruta_id, estacion_id, orden_parada) values
    ('00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000101', 1),
    ('00000000-0000-4000-8000-000000000201', '00000000-0000-4000-8000-000000000102', 2),
    ('00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000102', 1),
    ('00000000-0000-4000-8000-000000000202', '00000000-0000-4000-8000-000000000104', 2),
    ('00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000103', 1),
    ('00000000-0000-4000-8000-000000000203', '00000000-0000-4000-8000-000000000104', 2),
    ('00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000101', 1),
    ('00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000102', 2),
    ('00000000-0000-4000-8000-000000000204', '00000000-0000-4000-8000-000000000104', 3);

insert into tarifas (ruta_id, tipo_vehiculo_id, monto, moneda, vigente_desde) values
    (
        '00000000-0000-4000-8000-000000000201',
        '00000000-0000-4000-8000-000000000001',
        45.00, 'NIO', '2026-01-01T00:00:00Z'
    ),
    (
        '00000000-0000-4000-8000-000000000202',
        '00000000-0000-4000-8000-000000000001',
        90.00, 'NIO', '2026-01-01T00:00:00Z'
    ),
    (
        '00000000-0000-4000-8000-000000000203',
        '00000000-0000-4000-8000-000000000001',
        110.00, 'NIO', '2026-01-01T00:00:00Z'
    ),
    (
        '00000000-0000-4000-8000-000000000204',
        '00000000-0000-4000-8000-000000000001',
        130.00, 'NIO', '2026-01-01T00:00:00Z'
    ),
    (
        '00000000-0000-4000-8000-000000000204',
        '00000000-0000-4000-8000-000000000005',
        220.00, 'NIO', '2026-01-01T00:00:00Z'
    );

insert into configuracion (id, version) values (1, 1);
