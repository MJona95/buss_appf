-- ============================================================================
-- insertar_estaciones.sql
-- Inserta estaciones nuevas (y su vínculo a rutas) desde un arreglo JSON.
-- La geometría de rutas (ruta_puntos) quedó eliminada en Supabase (v6), por lo
-- que no hace falta tocar nada más: la app traza la ruta vía OSRM en runtime.
--
-- USO:
--   1) Reemplaza el arreglo JSON de abajo por tus estaciones.
--   2a) Supabase dashboard: pega TODO el archivo en SQL Editor y ejecuta.
--   2b) Terminal:  psql "$SUPABASE_DB_URL" -f supabase/scripts/insertar_estaciones.sql
--
-- Formato JSON por estación:
--   {
--     "nombre":       "Parada Mercado San José",
--     "latitud":      13.48612,
--     "longitud":     -86.58221,
--     "poblado":      true,               -- true/false (opcional, default false)
--     "ruta_id":      null,               -- UUID de la ruta (opcional por ahora)
--     "orden_parada": null                -- numero de parada en esa ruta
--   }
--
-- Si "ruta_id" y "orden_parada" vienen definidos, la estación se vincula a esa
-- ruta en ruta_estaciones. Sin ellos, la estación igual aparece en el mapa
-- (todas las estaciones activas se muestran) pero sin ruta/horario/tarifas.
--
-- El script es idempotente: no duplica estaciones con el mismo nombre ni
-- repite un vínculo (ruta_id + estacion_id) ya existente.
--
-- Al final sube configuracion.version (+1) para que la app detecte el cambio
-- y re-sincronice el catálogo. Las tarifas NO se tocan: la estación hereda las
-- tarifas de las rutas a las que pertenece.
-- ============================================================================

with datos as (
    -- >>> PEGA AQUI TU JSON DE ESTACIONES (reemplaza el arreglo completo) <<<
    select * from jsonb_to_recordset('
    [
        {
            "nombre":       "Parada Mercado San José",
            "latitud":      13.48612,
            "longitud":     -86.58221,
            "poblado":      false,
            "ruta_id":      null,
            "orden_parada": null
        },
        {
            "nombre":       "Parada Catedral de Somoto",
            "latitud":      13.48810,
            "longitud":     -86.58110,
            "poblado":      true,
            "ruta_id":      "00000000-0000-4000-8000-000000000201",
            "orden_parada": 3
        }
    ]
    '::jsonb) as t(
        nombre text,
        latitud double precision,
        longitud double precision,
        poblado boolean,
        ruta_id text,
        orden_parada integer
    )
),
-- 1) Insertar estaciones nuevas (salta nombres ya existentes)
ins_estaciones as (
    insert into estaciones (id, nombre, latitud, longitud, activo, poblado)
    select
        gen_random_uuid(),
        btrim(d.nombre),
        d.latitud,
        d.longitud,
        true,
        coalesce(d.poblado, false)
    from datos d
    where not exists (
        select 1
        from estaciones e
        where lower(btrim(e.nombre)) = lower(btrim(d.nombre))
    )
),
-- 2) Vincular a la ruta indicada (si ruta_id y orden_parada vienen definidos)
ins_ruta_estaciones as (
    insert into ruta_estaciones (id, ruta_id, estacion_id, orden_parada)
    select
        gen_random_uuid(),
        d.ruta_id::uuid,
        e.id,
        d.orden_parada
    from datos d
    join estaciones e on lower(btrim(e.nombre)) = lower(btrim(d.nombre))
    where d.ruta_id is not null
      and d.orden_parada is not null
      and not exists (
          select 1
          from ruta_estaciones re
          where re.ruta_id = d.ruta_id::uuid
            and re.estacion_id = e.id
      )
      and not exists (
          select 1
          from ruta_estaciones re
          where re.ruta_id = d.ruta_id::uuid
            and re.orden_parada = d.orden_parada
      )
)
-- 3) Bump de version para que la app re-sincronice
update configuracion
set version = version + 1
returning 'configuracion.version' as campo, version as nuevo_valor;