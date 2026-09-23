drop table if exists ruta_puntos;

update configuracion set version = 6, actualizado_en = now() where id = 1;