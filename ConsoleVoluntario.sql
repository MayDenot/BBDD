SET SEARCH_PATH = unc_esq_voluntario;

-- Seleccione el identificador y nombre de todas las instituciones que son Fundaciones.(V)
SELECT id_institucion, nombre_institucion
FROM institucion
WHERE nombre_institucion LIKE 'FUNDACION%';

--Muestre el apellido y el identificador de la tarea de todos los voluntarios que no tienen
--coordinador.
SELECT apellido, id_tarea
FROM voluntario
WHERE id_coordinador IS NULL;

-- Muestre el apellido, nombre y mail de todos los voluntarios cuyo teléfono comienza con
-- +51. Coloque el encabezado de las columnas de los títulos 'Apellido' y 'Nombre' y 'Dirección'
-- de 'mail'.
SELECT apellido || ' ' ||  nombre AS "Apellido y Nombre", e_mail AS "Dirección de mail"
FROM voluntario
WHERE telefono LIKE '+51%';

-- Recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios
-- nacidos desde 1990.
SELECT MIN(horas_aportadas) AS "Cantidad mínima  de horas aportadas",
       MAX(horas_aportadas) AS "Cantidad máxima de horas aportadas",
       AVG(horas_aportadas) AS "Promedio de horas aportadas"
FROM voluntario
WHERE fecha_nacimiento >= '1990-01-01'; -- O EXTRACT(YEAR FROM fecha_nacimiento) > 1990

--¿Cuántos cumpleaños de voluntarios hay cada mes?
SELECT EXTRACT(MONTH FROM fecha_nacimiento) AS Mes,
    COUNT(*) AS "Cantidad de cumpleaños por mes"
FROM voluntario
GROUP BY Mes
ORDER BY Mes;

--¿Cuáles son las 2 instituciones que más voluntarios tienen?
SELECT id_institucion,
    COUNT(*) AS cant_voluntarios
FROM voluntario
GROUP BY id_institucion
ORDER BY cant_voluntarios DESC LIMIT 2
OFFSET 0;