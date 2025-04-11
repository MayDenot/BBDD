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

-- 2.1. Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan
-- aportes. Ordene el resultado por nombre de institución.
SELECT i.nombre_institucion, COUNT(v.nro_voluntario) AS "Cant voluntarios aportan"
FROM institucion i JOIN voluntario v USING (id_institucion)
WHERE horas_aportadas IS NOT NULL
GROUP BY i.nombre_institucion
ORDER BY i.nombre_institucion;

-- 2.2. Determine la cantidad de coordinadores en cada país, agrupados por nombre de
-- país y nombre de continente. Etiquete la primera columna como 'Número de coordinadores'
SELECT COUNT(v.id_coordinador) AS "Número de coordinadores", p.nombre_pais, c.nombre_continente
FROM voluntario v JOIN institucion i USING (id_institucion)
JOIN direccion d USING (id_direccion)
JOIN pais p USING(id_pais)
JOIN continente c USING(id_continente)
GROUP BY p.nombre_pais, c.nombre_continente;

-- 2.3. Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de
-- cualquier voluntario que trabaje en la misma institución que el Sr. de apellido Zlotkey.
-- Excluya del resultado a Zlotkey.
SELECT v.apellido as apellido, v.nombre, v.fecha_nacimiento
FROM voluntario v
WHERE v.id_institucion IN (
    SELECT v.id_institucion
    FROM voluntario
    WHERE apellido = 'Zlotkey'
) AND v.apellido != 'Zlotkey';

-- 2.4. Cree una consulta para mostrar los números de voluntarios y los apellidos de todos
-- los voluntarios cuya cantidad de horas aportadas sea mayor que la media de las horas
-- aportadas. Ordene los resultados por horas aportadas en orden ascendente.
SELECT nro_voluntario, apellido
FROM voluntario
WHERE horas_aportadas > (
        SELECT AVG(horas_aportadas)
        FROM voluntario
    )
ORDER BY horas_aportadas;

