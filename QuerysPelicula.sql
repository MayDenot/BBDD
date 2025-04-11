SET SEARCH_PATH = unc_esq_peliculas;

--Seleccione el identificador de distribuidor, identificador de departamento y nombre de todos
--los departamentos.
SELECT id_distribuidor, id_departamento, nombre
FROM departamento;

--Muestre el nombre, apellido y el teléfono de todos los empleados cuyo id_tarea sea 7231,
--ordenados por apellido y nombre.
SELECT nombre, apellido, telefono
FROM empleado
WHERE id_tarea = '7231'
ORDER BY apellido, nombre;

-- Muestre el apellido e identificador de todos los empleados que no cobran porcentaje de
-- comisión
SELECT apellido, id_empleado
FROM empleado
WHERE porc_comision IS NULL;

--Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono.
SELECT *
FROM distribuidor
WHERE telefono IS NULL;

--Muestre los apellidos, nombres y mails de los empleados con cuentas de gmail y cuyo
--sueldo sea superior a $ 1000.
SELECT apellido, nombre, e_mail
FROM empleado
WHERE e_mail LIKE '%gmail.com%' AND sueldo > 1000;

-- Seleccione los diferentes identificadores de tareas que se utilizan en la tabla empleado.
SELECT DISTINCT id_tarea
FROM empleado;

-- Hacer un listado de los cumpleaños de todos los empleados donde se muestre el nombre y
-- el apellido (concatenados y separados por una coma) y su fecha de cumpleaños (solo el
-- día y el mes), ordenado de acuerdo al mes y día de cumpleaños en forma ascendente. INCOMPLETO
SELECT nombre || ', ' || apellido AS "Nombre y Apellido",
       EXTRACT(DAY FROM fecha_nacimiento) || '/' ||
       EXTRACT(MONTH FROM fecha_nacimiento) AS "Día y mes de cumpleaños"
FROM empleado
ORDER BY EXTRACT(DAY FROM fecha_nacimiento), EXTRACT(MONTH FROM fecha_nacimiento);

-- Listar la cantidad de películas que hay por cada idioma.
SELECT idioma AS "Idioma",
       COUNT(*) AS "Cantidad de peliculas"
FROM pelicula
GROUP BY idioma;

-- Calcular la cantidad de empleados por departamento.
SELECT id_departamento AS "ID Dpto",
       COUNT(*) AS "Cantidad de empleados"
FROM empleado
GROUP BY id_departamento;

--Mostrar los códigos de películas que han recibido entre 3 y 5 entregas. (veces entregadas,
--NO cantidad de películas entregadas).
SELECT codigo_pelicula
FROM renglon_entrega
WHERE cantidad BETWEEN 3 AND 5;

--¿Cuáles son los id de ciudades que tienen más de un departamento?
SELECT id_ciudad,
    COUNT(id_departamento) AS cant_depto
FROM departamento
GROUP BY id_ciudad
HAVING COUNT(id_departamento) > 1
ORDER BY cant_depto DESC;

-- Parte 2

-- Ejercicio 1
-- 1.1 Listar todas las películas que poseen entregas de películas de idioma inglés durante
-- el año 2006. (P)
SELECT *
FROM pelicula p
WHERE EXISTS (
    SELECT e.fecha_entrega
    FROM entrega e
    WHERE EXTRACT(YEAR FROM e.fecha_entrega) = '2006'
) AND p.idioma LIKE 'Inglés';

-- 1.2 Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor
-- nacional. Trate de resolverlo utilizando ensambles.(P)
SELECT COUNT(*) AS "Cant peliculas"
FROM pelicula p
WHERE EXISTS(
  SELECT *
  FROM entrega e JOIN nacional n ON (e.id_distribuidor = n.id_distribuidor)
  WHERE EXTRACT(YEAR FROM e.fecha_entrega) = '2006'
);

-- 1.3 Indicar los departamentos que no posean empleados cuya diferencia de sueldo
-- máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del sueldo máximo.
-- (P) (Probar con 10% para que retorne valores)
SELECT nombre AS Dpto
FROM departamento
WHERE id_departamento NOT IN (
    SELECT id_empleado
    FROM empleado e JOIN tarea t USING(id_tarea)
    WHERE (t.sueldo_maximo - t.sueldo_minimo) <= (sueldo_maximo * 0.1)
);

-- 1.4 Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)
SELECT *
FROM pelicula p
WHERE EXISTS (
  SELECT id_distribuidor
  FROM entrega e JOIN internacional inter USING (id_distribuidor)
);

-- 1.5 Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del
-- jefe) se encuentren en la Argentina. FALTA COMPLETAR
SELECT *
FROM empleado e
WHERE id_empleado IN (
    SELECT id_departamento
    FROM departamento d
    WHERE jefe_departamento = e.id_empleado
);

-- 1.6 Liste el apellido y nombre de los empleados que pertenecen a aquellos
-- departamentos de Argentina y donde el jefe de departamento posee una comisión de más
-- del 10% de la que posee su empleado a cargo.
SELECT e.apellido, e.nombre
FROM empleado e
WHERE EXISTS (
    SELECT 1
    FROM departamento d
        JOIN ciudad c USING (id_ciudad)
        JOIN pais p USING (id_pais)
        JOIN empleado j ON j.id_empleado = d.jefe_departamento
    WHERE p.nombre_pais = 'Argentina'
      AND d.id_departamento = e.id_departamento
      AND j.porc_comision > (e.porc_comision * 0.1)
);

-- 1.7 Indicar la cantidad de películas entregadas a partir del 2010, por género.
SELECT genero, COUNT(*) "Cant peliculas por género"
FROM pelicula JOIN renglon_entrega re USING (codigo_pelicula)
JOIN entrega e USING (nro_entrega)
WHERE EXTRACT(YEAR FROM e.fecha_entrega) >= '2010'
GROUP BY genero;

-- 1.8 Realizar un resumen de entregas por día, indicando el videoclub al cual se le
-- realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.
SELECT EXTRACT(DAY FROM e.fecha_entrega) AS Dia, COUNT(v.id_video) "Cant entregas", v.id_video
FROM entrega e JOIN video v USING(id_video)
GROUP BY Dia, v.id_video
ORDER BY 2;

-- 1.9 Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados
-- mayores de edad que desempeñan tareas en departamentos de la misma y que posean al
-- menos 30 empleados.
SELECT c.nombre_ciudad AS "Ciudad", COUNT(e.id_empleado) AS "Cantidad Empleados"
FROM ciudad c JOIN departamento d USING (id_ciudad)
JOIN empleado e USING (id_departamento)
WHERE d.id_ciudad = c.id_ciudad AND
d.id_departamento = e.id_departamento AND
EXTRACT(YEARS FROM AGE(e.fecha_nacimiento)) >= 18
GROUP BY c.nombre_ciudad; -- FALTA QUE EL DEPTO TENGA AL MENOS 30 EMPLEADOS

-- Ejercicio 3
-- 3.1 Se solicita llenarla con la información correspondiente a los datos completos de
-- todos los distribuidores nacionales.

-- 3.2 Agregar a la definición de la tabla distribuidor_nac, el campo "codigo_pais"; que
-- indica el código de país del distribuidor mayorista que atiende a cada distribuidor
-- nacional.(codigo_pais varchar(5) NULL)

-- 3.3. Para todos los registros de la tabla distribuidor_nac, llenar el nuevo campo
-- "codigo_pais" con el valor correspondiente existente en la tabla "Internacional";.

-- 3.4. Eliminar de la tabla distribuidor_nac los registros que no tienen asociado un
-- distribuidor mayorista.