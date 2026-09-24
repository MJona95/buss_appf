alter table rutas
    add column tipo_servicio text not null default 'ruteado';

alter table rutas
    add constraint rutas_tipo_servicio_check
    check (tipo_servicio in ('ruteado', 'expreso'));

alter table vehiculos
    add column tipo_servicio text not null default 'ruteado';

alter table vehiculos
    add constraint vehiculos_tipo_servicio_check
    check (tipo_servicio in ('ruteado', 'expreso'));

insert into rutas (
    id, nombre, origen_nombre, destino_nombre,
    origen_lat, origen_lng, destino_lat, destino_lng,
    tipo_servicio
) values
    (
        '00000000-0000-4000-8000-000000000221',
        'Somoto - Managua (Expreso)',
        'Somoto', 'Managua',
        13.48858, -86.58185, 12.13422, -86.19338,
        'expreso'
    ),
    (
        '00000000-0000-4000-8000-000000000222',
        'Estelí - Managua (Expreso)',
        'Estelí', 'Managua',
        13.07620, -86.35200, 12.13422, -86.19338,
        'expreso'
    );

insert into vehiculos (
    id, nombre, placa, tipo_vehiculo_id, tipo_transporte,
    capacidad, activo, tipo_servicio
) values
    (
        '00000000-0000-4000-8000-000000000305',
        'Unidad 21', '21',
        '00000000-0000-4000-8000-000000000001',
        'public', 45, true, 'expreso'
    ),
    (
        '00000000-0000-4000-8000-000000000306',
        'Unidad 24', '24',
        '00000000-0000-4000-8000-000000000001',
        'public', 40, true, 'expreso'
    );

insert into vehiculo_rutas (vehiculo_id, ruta_id) values
    ('00000000-0000-4000-8000-000000000305', '00000000-0000-4000-8000-000000000221'),
    ('00000000-0000-4000-8000-000000000306', '00000000-0000-4000-8000-000000000222');

insert into ruta_estaciones (ruta_id, estacion_id, orden_parada) values
    ('00000000-0000-4000-8000-000000000221', '00000000-0000-4000-8000-000000000101', 1),
    ('00000000-0000-4000-8000-000000000221', '00000000-0000-4000-8000-000000000104', 2),
    ('00000000-0000-4000-8000-000000000222', '00000000-0000-4000-8000-000000000102', 1),
    ('00000000-0000-4000-8000-000000000222', '00000000-0000-4000-8000-000000000104', 2);

insert into tarifas (ruta_id, tipo_vehiculo_id, monto, moneda, vigente_desde) values
    (
        '00000000-0000-4000-8000-000000000221',
        '00000000-0000-4000-8000-000000000001',
        160.00, 'NIO', '2026-01-01T00:00:00Z'
    ),
    (
        '00000000-0000-4000-8000-000000000222',
        '00000000-0000-4000-8000-000000000001',
        110.00, 'NIO', '2026-01-01T00:00:00Z'
    );

insert into horarios (id, ruta_id, vehiculo_id, hora_salida, hora_llegada) values
    (
        '00000000-0000-4000-8000-000000000711',
        '00000000-0000-4000-8000-000000000221',
        '00000000-0000-4000-8000-000000000305',
        '07:00', '10:20'
    ),
    (
        '00000000-0000-4000-8000-000000000712',
        '00000000-0000-4000-8000-000000000222',
        '00000000-0000-4000-8000-000000000306',
        '08:00', '11:05'
    );

update configuracion
set version = 8, actualizado_en = now()
where id = 1;