create table horarios (
    id uuid primary key default gen_random_uuid(),
    ruta_id uuid not null
        references rutas(id)
        on delete cascade,
    vehiculo_id uuid not null
        references vehiculos(id)
        on delete cascade,
    hora_salida text not null,
    hora_llegada text not null,
    activo boolean default true,
    creado_en timestamptz default now(),
    unique (ruta_id, vehiculo_id, hora_salida)
);

alter table horarios enable row level security;
create policy lectura_horarios on horarios for select using (true);

insert into horarios (id, ruta_id, vehiculo_id, hora_salida, hora_llegada) values
    (
        '00000000-0000-4000-8000-000000000701',
        '00000000-0000-4000-8000-000000000201',
        '00000000-0000-4000-8000-000000000301',
        '05:30', '06:47'
    ),
    (
        '00000000-0000-4000-8000-000000000702',
        '00000000-0000-4000-8000-000000000204',
        '00000000-0000-4000-8000-000000000301',
        '07:00', '10:50'
    ),
    (
        '00000000-0000-4000-8000-000000000703',
        '00000000-0000-4000-8000-000000000202',
        '00000000-0000-4000-8000-000000000302',
        '08:30', '11:03'
    ),
    (
        '00000000-0000-4000-8000-000000000704',
        '00000000-0000-4000-8000-000000000203',
        '00000000-0000-4000-8000-000000000303',
        '05:00', '08:58'
    ),
    (
        '00000000-0000-4000-8000-000000000705',
        '00000000-0000-4000-8000-000000000204',
        '00000000-0000-4000-8000-000000000304',
        '07:00', '10:31'
    );

update configuracion set version = 3, actualizado_en = now() where id = 1;