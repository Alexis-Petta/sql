--1
SELECT clie_codigo, clie_razon_social FROM Cliente WHERE clie_limite_credito >= 1000 ORDER BY clie_codigo;

--2
SELECT prod_codigo, prod_detalle, SUM(item_cantidad) AS 'TOTAL VENDIDO' FROM Producto
LEFT JOIN Item_Factura
ON prod_codigo = item_producto
LEFT JOIN Factura
ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
WHERE YEAR(fact_fecha)=2012
GROUP BY
prod_codigo,
prod_detalle
ORDER BY SUM(item_cantidad) desc;

--3
SELECT prod_codigo, prod_detalle, SUM(stoc_cantidad) AS 'STOCK TOTAL' FROM Producto
LEFT JOIN Stock
ON prod_codigo = stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle ASC;

--4
SELECT comp_producto, prod_detalle, COUNT(distinct comp_cantidad) AS 'cantidad de productos'FROM Composicion
LEFT JOIN producto
ON comp_producto = prod_codigo
LEFT JOIN STOCK
ON comp_producto = stoc_producto
GROUP BY comp_producto, prod_detalle
HAVING AVG(stoc_cantidad) > 100;

--5
SELECT
    p.prod_codigo,
    p.prod_detalle,
    SUM(i.item_cantidad) AS vendido_2012
FROM Producto p
JOIN Item_Factura i
    ON p.prod_codigo = i.item_producto
JOIN Factura f
    ON f.fact_tipo = i.item_tipo
    AND f.fact_sucursal = i.item_sucursal
    AND f.fact_numero = i.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY
    p.prod_codigo,
    p.prod_detalle
HAVING SUM(i.item_cantidad) > (
    SELECT ISNULL(SUM(i2.item_cantidad), 0)
    FROM Item_Factura i2
    JOIN Factura f2
        ON f2.fact_tipo = i2.item_tipo
        AND f2.fact_sucursal = i2.item_sucursal
        AND f2.fact_numero = i2.item_numero
    WHERE YEAR(f2.fact_fecha) = 2011
      AND i2.item_producto = p.prod_codigo
);

--6
SELECT rubr_id, rubr_detalle, COUNT(prod_rubro), sum(isnull(stoc_cantidad,0)) 
FROM Rubro LEFT JOIN Producto ON prod_rubro = rubr_id
LEFT JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY rubr_id, rubr_detalle
HAVING SUM(stoc_cantidad) > (SELECT stoc_cantidad FROM Producto
                        JOIN STOCK ON prod_codigo = stoc_producto
                        JOIN DEPOSITO ON stoc_deposito = depo_codigo
                        WHERE prod_codigo= '00000000' AND depo_codigo='00');

--7
SELECT prod_codigo, prod_detalle, 
    MAX(item_precio)  PrecioMAX, 
    MIN(item_precio)  PrecioMIN,
    (((MAX(item_precio) - MIN(item_precio)) / MIN(item_precio))
    *100)
FROM Producto
JOIN STOCK ON prod_codigo = stoc_producto
JOIN Item_Factura ON item_producto = prod_codigo
WHERE stoc_cantidad>0
GROUP BY prod_codigo, prod_detalle;

--8
/*8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del 
artículo, stock del depósito que más stock tiene. */

SELECT prod_detalle, MAX(stoc_cantidad) FROM Producto
JOIN STOCK ON prod_codigo = stoc_producto
GROUP BY prod_detalle
HAVING MIN(stoc_cantidad) > 0;

--9
/*9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del 
mismo y la cantidad de depósitos que ambos tienen asignados. */

SELECT  empl.empl_jefe,  
        empl.empl_codigo,
        empl.empl_nombre,
        (ISNULL((SELECT COUNT(depo_codigo) FROM Deposito WHERE depo_encargado = empl.empl_codigo GROUP BY depo_encargado), 0)) + (ISNULL((SELECT COUNT(depo_codigo) FROM Deposito WHERE depo_encargado = empl.empl_jefe GROUP BY depo_encargado), 0))
FROM Empleado empl
JOIN Empleado jefe ON empl.empl_jefe = jefe.empl_codigo;

--10
/*10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos 
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que 
mayor compra realizo. */

--TODO

--11
/*11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de 
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán 
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga, 
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para 
el año 2012. */

SELECT fami_detalle, COUNT(DISTINCT prod_codigo) AS 'productos_vendidos', SUM(item_cantidad*item_precio) AS 'ventas_sin_impuestos' FROM Factura
LEFT JOIN Item_factura ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
LEFT JOIN Producto ON item_producto = prod_codigo 
LEFT JOIN Familia ON fami_id = prod_familia
WHERE item_cantidad > 0 AND YEAR(fact_fecha) = 2012
GROUP BY fami_detalle
HAVING SUM(item_cantidad*item_precio) > 20000 
ORDER BY COUNT(DISTINCT prod_codigo) desc;

--12
/* 12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron importe 
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del 
producto y stock actual del producto en todos los depósitos. Se deberán mostrar 
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán 
ordenarse de mayor a menor por monto vendido del producto. */

SELECT prod_detalle, COUNT(Distinct fact_cliente) Cantidad_de_clientes_distintos, AVG(item_precio) importe_promedio_pagado, count(distinct stoc_deposito) cantidad_de_depósitos_en_los_cuales_hay_stock, SUM(stoc_cantidad) stock_actual FROM Producto
LEFT JOIN item_factura ON prod_codigo = item_producto
LEFT JOIN factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
LEFT JOIN stock ON prod_codigo = stoc_producto
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad * item_precio) DESC

--13
/*13. Realizar una consulta que retorne para cada producto que posea composición  nombre 
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad 
de los productos que lo componen. Solo se deberán mostrar los productos que estén 
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por 
cantidad de productos que lo componen.  */

--TODO

--14

/*14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que 
debe retornar son: 
 
Código del cliente 
Cantidad de veces que compro en el último año 
Promedio por compra en el último año 
Cantidad de productos diferentes que compro en el último año 
Monto de la mayor compra que realizo en el último año 
 
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en 
el último año. 
No se deberán visualizar NULLs en ninguna columna*/

SELECT 
    clie_codigo,
    ISNULL((    SELECT COUNT(fact_numero) FROM Factura
                WHERE YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) FROM Factura) AND clie_codigo = fact_cliente
                GROUP BY fact_cliente),0)
        Veces_ultimo_anio,
    ISNULL((    SELECT avg(fact_total) FROM Factura
                WHERE YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) FROM Factura) AND clie_codigo = fact_cliente
                GROUP BY fact_cliente),0)
        Promedio_Ultimo_Anio,
    ISNULL((    SELECT count(distinct item_producto) FROM Factura
                JOIN item_factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                WHERE YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) FROM Factura) AND clie_codigo = fact_cliente
                GROUP BY fact_cliente),0)
        Cantidad_productos_diferentes ,
    ISNULL((    SELECT MAX(fact_total) FROM Factura
                WHERE YEAR(fact_fecha) = (SELECT YEAR(MAX(fact_fecha)) FROM Factura) AND clie_codigo = fact_cliente
                GROUP BY fact_cliente),0)
        Monto_mayor 
    FROM Cliente
    ORDER BY Veces_ultimo_anio desc;

--15

/*15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos 
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y 
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos 
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron 
juntos dichos productos. Los distintos pares no deben retornarse más de una vez. 
 
Ejemplo de lo que retornaría la consulta: 
  
PROD1       DETALLE1            PROD2       DETALLE2                    VECES 
1731        MARLBORO KS         1 7 1 8     P H ILIPS MORRIS KS         5 0 7 
1718        PHILIPS MORRIS KS   1 7 0 5     P H I L I P S MORRIS BOX    10 5 6 2 */

SELECT i1.item_producto,
       p1.prod_detalle,
       i2.item_producto,
       p2.prod_detalle,
       COUNT(*)
FROM item_factura i1
LEFT JOIN  Producto p1 ON i1.item_producto = p1.prod_codigo
JOIN Item_Factura i2
    ON i1.item_tipo = i2.item_tipo
   AND i1.item_sucursal = i2.item_sucursal
   AND i1.item_numero = i2.item_numero
   AND i1.item_producto < i2.item_producto
LEFT JOIN Producto p2 ON i2.item_producto = p2.prod_codigo
GROUP BY i1.item_producto, p1.prod_detalle, i2.item_producto, p2.prod_detalle
HAVING COUNT(*) > 500
ORDER BY COUNT(*)

--16
/*

16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran 
en la empresa, se pide una consulta SQL que retorne aquellos *//*. 
 
Además mostrar 
 
1. Nombre del Cliente 
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente. 
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1, 
mostrar solamente el de menor código) para ese cliente. 
 
Aclaraciones: 
 
La composición es de 2 niveles, es decir, un producto compuesto solo se compone de 
productos no compuestos. 
Los clientes deben ser ordenados por código de provincia ascendente. */


--TODO

--17
/*

Escriba una consulta que retorne una estadística de ventas por año y mes para cada 
producto. 
 
La consulta debe retornar: 
 
PERIODO: Año y mes de la estadística con el formato YYYYMM 
PROD: Código de producto 
DETALLE: Detalle del producto 
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo 
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo 
pero del año anterior 
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el 
periodo 
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada 
por periodo y código de producto.

*/


--TODO

/* 18. Escriba una consulta que retorne una estadística de ventas para todos los rubros. 
La consulta debe retornar: 
DETALLE_RUBRO: Detalle del rubro 
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro 
PROD1: Código del producto más vendido de dicho rubro 
PROD2: Código del segundo producto más vendido de dicho rubro 
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30 
días 
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada 
por cantidad de productos diferentes vendidos del rubro. */

SELECT  rubr_detalle,
            ISNULL(SUM(item_cantidad * item_precio), 0)
        VENTAS,
            ISNULL((SELECT TOP 1 I1.item_producto FROM Item_Factura I1
                JOIN Producto P1 ON I1.item_producto = P1.prod_codigo
                WHERE P1.prod_rubro = rubr_id
                GROUP BY prod_rubro, I1.item_producto
                ORDER BY SUM(I1.item_cantidad) desc), 0) 
        PROD1,
            ISNULL((SELECT TOP 1 I1.item_producto FROM Item_Factura I1
                JOIN Producto P1 ON I1.item_producto = P1.prod_codigo
                WHERE P1.prod_rubro = rubr_id AND prod_codigo != (  SELECT TOP 1 I1.item_producto FROM Item_Factura I1
                                                                    JOIN Producto P1 ON I1.item_producto = P1.prod_codigo
                                                                    WHERE P1.prod_rubro = rubr_id
                                                                    GROUP BY prod_rubro, I1.item_producto
                                                                    ORDER BY SUM(I1.item_cantidad) desc)
                GROUP BY prod_rubro, I1.item_producto
                ORDER BY SUM(I1.item_cantidad) desc), 0)
        PROD2,
            ISNULL((SELECT TOP 1 f1.fact_cliente FROM Factura f1
                    LEFT JOIN Item_Factura I1 ON I1.item_sucursal = f1.fact_sucursal AND I1.item_tipo = f1.fact_tipo AND I1.item_numero = f1.fact_numero
                    LEFT JOIN Producto P1 ON I1.item_producto = P1.prod_codigo
                    LEFT JOIN Rubro R1 ON R1.rubr_id = prod_rubro
                    WHERE f1.fact_fecha > (SELECT TOP 1 f2.fact_fecha-30 FROM factura f2
                                                                    ORDER BY f2.fact_fecha desc)
                          AND rubr_id = P1.prod_rubro
                    GROUP BY f1.fact_cliente, R1.rubr_id
                    ORDER BY SUM(I1.item_cantidad) desc), 0)
FROM rubro
LEFT JOIN Producto ON rubr_id = prod_rubro
LEFT JOIN Item_Factura ON prod_codigo = item_producto
GROUP BY rubr_id, rubr_detalle
ORDER BY COUNT(DISTINCT prod_codigo) DESC

SELECT fact_cliente, rubr_id, SUM(item_cantidad) FROM Factura
LEFT JOIN Item_Factura ON item_sucursal = fact_sucursal AND item_tipo = fact_tipo AND item_numero = fact_numero
LEFT JOIN Producto ON item_producto = prod_codigo
LEFT JOIN Rubro ON rubr_id = prod_rubro
WHERE year(fact_fecha)*100+Month(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha) * 100 + MONTH(fact_fecha) FROM factura
                                                ORDER BY YEAR(fact_fecha) desc, MONTH(fact_fecha) desc)
GROUP BY fact_cliente, rubr_id
ORDER BY SUM(item_cantidad) desc

SELECT YEAR(fact_fecha) * 100 + MONTH(fact_fecha) FROM factura
ORDER BY YEAR(fact_fecha) desc, MONTH(fact_fecha) desc

--CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30 días 

/*

19. En virtud de una recategorizacion de productos referida a la familia de los mismos  se 
solicita que desarrolle una consulta sql que retorne para todos los productos: 
     Codigo de producto 
     Detalle del producto 
     Codigo de la familia del producto 
     Detalle de la familia actual del producto 
     Codigo de la familia sugerido para el producto 
     Detalla de la familia sugerido para el producto 
La familia sugerida para un producto es la que poseen la mayoria de los productos cuyo 
detalle coinciden en los primeros 5 caracteres. 
En caso que 2 o mas familias pudieran ser sugeridas se debera seleccionar la de menor 
codigo.  Solo se deben mostrar los productos para los cuales la familia actual sea 
diferente a la sugerida 
Los resultados deben ser ordenados por detalle de producto de manera ascendente


*/


SELECT  p1.prod_codigo, 
        p1.prod_detalle,    
        p1.prod_familia, 
        f1.fami_detalle,
        (SELECT TOP 1 f2.fami_id FROM Familia f2
            LEFT JOIN producto p2 ON p2.prod_familia = fami_id
            WHERE LEFT(p2.prod_detalle, 5) = left(p1.prod_detalle, 5)
            GROUP BY f2.fami_detalle, f2.fami_id
            ORDER BY COUNT(p2.prod_codigo)desc , f2.fami_id asc)
            FAMILIA_ID_SUGERIDA,
         (SELECT TOP 1 LEFT(p2.prod_detalle, 5) FROM Familia f2
            LEFT JOIN producto p2 ON p2.prod_familia = fami_id
            WHERE LEFT(p2.prod_detalle, 5) = left(p1.prod_detalle, 5)
            GROUP BY p2.prod_detalle, f2.fami_id
            ORDER BY COUNT(p2.prod_codigo)desc , f2.fami_id asc)
            FAMILIA_DETALLE_SUGERIDA
FROM Producto p1
LEFT JOIN familia f1 ON p1.prod_familia = f1.fami_id
WHERE p1.prod_familia != (SELECT TOP 1 f2.fami_id FROM Familia f2
                            LEFT JOIN producto p2 ON p2.prod_familia = fami_id
                            WHERE LEFT(f2.fami_detalle, 5) = left(f1.fami_detalle, 5)
                            GROUP BY f2.fami_detalle, f2.fami_id
                            ORDER BY COUNT(p2.prod_codigo)desc , f2.fami_id asc) 
 ORDER BY p1.prod_detalle asc;

 --20

 /*

 20. Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012 
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje 
2012.  El puntaje de cada empleado se calculara de la siguiente manera: para los que 
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas 
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50 
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas 
por sus subordinados directos en dicho año. 

 */

--TODO


--22

/*Ejercicio 22 de SQL

Escriba una consulta SQL que retorne una estadística de venta para todos los rubros por trimestre, contabilizando todos los años. Se mostrarán como máximo 4 filas por rubro, una por cada trimestre.

La consulta debe retornar:

Detalle del rubro
Número de trimestre del año, de 1 a 4
Cantidad de facturas emitidas en el trimestre en las que se haya vendido al menos un producto del rubro
Cantidad de productos diferentes del rubro vendidos en el trimestre

Condiciones:

El resultado debe estar ordenado alfabéticamente por detalle del rubro.
Dentro de cada rubro, primero debe aparecer el trimestre en el que más facturas se emitieron.
No se deberán mostrar rubros y trimestres para los cuales las facturas emitidas no superen las 100.
No se deben tener en cuenta productos compuestos.*/

SELECT
    R.rubr_detalle AS DETALLE_RUBRO,
    DATEPART(QUARTER, F.fact_fecha) AS TRIMESTRE,
    COUNT(DISTINCT F.fact_tipo + F.fact_sucursal + F.fact_numero) AS CANT_FACTURAS,
    COUNT(DISTINCT P.prod_codigo) AS CANT_PRODUCTOS_DISTINTOS
FROM Rubro R
JOIN Producto P
    ON P.prod_rubro = R.rubr_id
JOIN Item_Factura I
    ON I.item_producto = P.prod_codigo
JOIN Factura F
    ON F.fact_tipo = I.item_tipo
   AND F.fact_sucursal = I.item_sucursal
   AND F.fact_numero = I.item_numero
LEFT JOIN Composicion C
    ON C.comp_producto = P.prod_codigo
WHERE C.comp_producto IS NULL
GROUP BY
    R.rubr_detalle,
    DATEPART(QUARTER, F.fact_fecha)
HAVING COUNT(DISTINCT F.fact_tipo + F.fact_sucursal + F.fact_numero) > 100
ORDER BY
    R.rubr_detalle ASC,
    COUNT(DISTINCT F.fact_tipo + F.fact_sucursal + F.fact_numero) DESC;

--28
/*
Ejercicio 28 de SQL

Escriba una consulta SQL que retorne una estadística por año y vendedor.

La consulta debe retornar:

Año
Código de vendedor
Detalle del vendedor
Cantidad de facturas que realizó en ese año
Cantidad de clientes a los cuales les vendió en ese año
Cantidad de productos facturados con composición en ese año
Cantidad de productos facturados sin composición en ese año
Monto total vendido por ese vendedor en ese año

Condiciones:

Los datos deberán estar ordenados por año.
Dentro de cada año, ordenar por el vendedor que haya vendido más productos diferentes, de mayor a menor.
*/

SELECT  YEAR(F.fact_fecha), 
        E.empl_codigo, 
        E.empl_nombre, 
        E.empl_apellido,
        COUNT(F.fact_numero),
        COUNT(DISTINCT F.fact_cliente),

        ISNULL((SELECT COUNT(DISTINCT c.comp_producto) 
            FROM Composicion C 
            LEFT JOIN Item_Factura I2 
                ON item_producto = c.comp_producto 
            LEFT JOIN Factura F2 
                ON F2.fact_tipo = I2.item_tipo AND F2.fact_sucursal = I2.item_sucursal AND F2.fact_numero = I2.item_numero 
          WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha) AND F2.fact_vendedor = E.empl_codigo
          GROUP BY F2.fact_vendedor), 0) AS productos_con_composicion,

        ISNULL((SELECT COUNT(DISTINCT P2.prod_codigo) 
            FROM Producto P2 
            LEFT JOIN Composicion C
                ON P2.prod_codigo = C.comp_producto
            LEFT JOIN Item_Factura I2 
                ON item_producto = P2.prod_codigo 
            LEFT JOIN Factura F2 
                ON F2.fact_tipo = I2.item_tipo AND F2.fact_sucursal = I2.item_sucursal AND F2.fact_numero = I2.item_numero 
          WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha) AND F2.fact_vendedor = E.empl_codigo 
          GROUP BY F2.fact_vendedor), 0) AS productos_sin_composicion,

        ISNULL((SELECT COUNT(DISTINCT c.comp_producto) 
            FROM Composicion C 
            LEFT JOIN Item_Factura I2 
                ON item_producto = c.comp_producto 
            LEFT JOIN Factura F2 
                ON F2.fact_tipo = I2.item_tipo AND F2.fact_sucursal = I2.item_sucursal AND F2.fact_numero = I2.item_numero 
          WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha) AND F2.fact_vendedor = E.empl_codigo
          GROUP BY F2.fact_vendedor), 0)

        +

        ISNULL((SELECT COUNT(DISTINCT P2.prod_codigo) 
            FROM Producto P2 
            LEFT JOIN Composicion C
                ON P2.prod_codigo = C.comp_producto
            LEFT JOIN Item_Factura I2 
                ON item_producto = P2.prod_codigo 
            LEFT JOIN Factura F2 
                ON F2.fact_tipo = I2.item_tipo AND F2.fact_sucursal = I2.item_sucursal AND F2.fact_numero = I2.item_numero 
          WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha) AND F2.fact_vendedor = E.empl_codigo 
          GROUP BY F2.fact_vendedor), 0) Monto_total
FROM Empleado E
LEFT JOIN FACTURA F ON E.empl_codigo = F.fact_vendedor
GROUP BY YEAR(F.fact_fecha), E.empl_codigo, E.empl_nombre, E.empl_apellido
ORDER BY YEAR(F.fact_fecha) ASC, Monto_total DESC


--29
/*

Se requiere realizar una estadística de venta de productos para el año 2011, solo para los productos que pertenezcan a las familias que tengan más de 20 productos asignados.

La consulta debe devolver:

Código de producto
Descripción del producto
Cantidad vendida
Cantidad de facturas en las que está ese producto
Monto total facturado de ese producto

Condiciones:

Solo mostrar productos pertenecientes a familias con más de 20 productos.
Solo considerar ventas del año 2011.
Un producto por fila.
Ordenar por cantidad vendida de mayor a menor.

*/

SELECT  I.Item_producto, 
        P.prod_detalle, 
        SUM(I.item_cantidad) Cantidad_vendida, 
        COUNT(DISTINCT item_numero) Cantidad_de_facturas, 
        SUM(I.item_cantidad * I.Item_precio) Monto_total
FROM Item_Factura I
LEFT JOIN Factura F ON I.item_tipo = F.fact_tipo AND I.item_sucursal = F.fact_sucursal AND I.item_numero = F.fact_numero
LEFT JOIN Producto P ON I.item_producto = P.prod_codigo
WHERE YEAR(F.fact_fecha) = 2011 AND (SELECT COUNT(DISTINCT p2.prod_codigo) from Producto P2 WHERE p2.prod_familia = p.prod_familia GROUP BY p2.prod_familia) > 20
GROUP BY I.Item_producto, P.prod_detalle
ORDER BY Cantidad_vendida desc


--30

/*

Ejercicio SQL 30

Se desea obtener una estadística de ventas del año 2012 para los empleados que sean jefes, o sea, que tengan empleados a su cargo.

La consulta debe retornar:

Nombre del jefe
Cantidad de empleados a cargo
Monto total vendido por los empleados a cargo
Cantidad de facturas realizadas por los empleados a cargo
Nombre del empleado con mejores ventas de ese jefe

Condiciones:

Solo se permite el uso de una subconsulta, si fuese necesaria.
Ordenar de mayor a menor por el total vendido.
Solo mostrar los jefes cuyos subordinados hayan realizado más de 10 facturas.

Este es buen ejercicio para practicar Empleado contra Empleado, Factura, GROUP BY y HAVING.

*/

SELECT  
    J.empl_nombre AS Nombre_Jefe, 
    COUNT(DISTINCT S.empl_codigo) AS empleados_a_cargo,
    SUM(I.item_cantidad * I.item_precio) AS Monto_total,
    COUNT(DISTINCT CONCAT(F.fact_tipo, F.fact_sucursal, F.fact_numero)) AS Cantidad_de_facturas,

    (
        SELECT TOP 1 S2.empl_nombre
        FROM Empleado S2
        JOIN Factura F2
            ON F2.fact_vendedor = S2.empl_codigo
        JOIN Item_Factura I2
            ON I2.item_tipo = F2.fact_tipo
           AND I2.item_sucursal = F2.fact_sucursal
           AND I2.item_numero = F2.fact_numero
        WHERE S2.empl_jefe = J.empl_codigo
          AND YEAR(F2.fact_fecha) = 2012
        GROUP BY S2.empl_codigo, S2.empl_nombre
        ORDER BY SUM(I2.item_cantidad * I2.item_precio) DESC
    ) AS Mayor_vendedor

FROM Empleado J
JOIN Empleado S
    ON J.empl_codigo = S.empl_jefe
JOIN Factura F
    ON F.fact_vendedor = S.empl_codigo
JOIN Item_Factura I
    ON I.item_tipo = F.fact_tipo
   AND I.item_sucursal = F.fact_sucursal
   AND I.item_numero = F.fact_numero
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY 
    J.empl_nombre, 
    J.empl_codigo
HAVING COUNT(DISTINCT CONCAT(F.fact_tipo, F.fact_sucursal, F.fact_numero)) > 10
ORDER BY Monto_total DESC;

--32

/*

Se desea conocer las familias cuyos productos se facturaron juntos en las mismas facturas.

Escriba una consulta SQL que retorne los pares de familias que tienen productos facturados juntos.

La consulta debe devolver:

Código de familia
Detalle de familia
Código de familia
Detalle de familia
Cantidad de facturas
Total vendido

Condiciones:

Los datos deberán estar ordenados por total vendido.
Solo se deben mostrar las familias que se vendieron juntas más de 10 veces.
No repetir el mismo par dos veces.

*/

WITH FamiliaPorFactura AS (
    SELECT
        I.item_tipo,
        I.item_sucursal,
        I.item_numero,
        P.prod_familia,
        SUM(I.item_cantidad * I.item_precio) AS monto_familia
    FROM Item_Factura I
    JOIN Producto P
        ON P.prod_codigo = I.item_producto
    GROUP BY
        I.item_tipo,
        I.item_sucursal,
        I.item_numero,
        P.prod_familia
)

SELECT
    FPF1.prod_familia AS familia_1,
    FAM1.fami_detalle AS detalle_familia_1,
    FPF2.prod_familia AS familia_2,
    FAM2.fami_detalle AS detalle_familia_2,
    COUNT(*) AS cantidad_facturas,
    SUM(FPF1.monto_familia + FPF2.monto_familia) AS total_vendido
FROM FamiliaPorFactura FPF1
JOIN FamiliaPorFactura FPF2
    ON FPF1.item_tipo = FPF2.item_tipo
   AND FPF1.item_sucursal = FPF2.item_sucursal
   AND FPF1.item_numero = FPF2.item_numero
   AND FPF1.prod_familia < FPF2.prod_familia
JOIN Familia FAM1
    ON FAM1.fami_id = FPF1.prod_familia
JOIN Familia FAM2
    ON FAM2.fami_id = FPF2.prod_familia
GROUP BY
    FPF1.prod_familia,
    FAM1.fami_detalle,
    FPF2.prod_familia,
    FAM2.fami_detalle
HAVING COUNT(*) > 10
ORDER BY
    total_vendido DESC;

--34

/*Ejercicio 34 de SQL

Escriba una consulta SQL que retorne, para todos los rubros, la cantidad de facturas mal facturadas por cada mes del año 2011.

Se considera que una factura es incorrecta cuando en la misma factura se facturan productos de dos rubros diferentes.

La consulta debe mostrar:

Código de rubro
Mes
Cantidad de facturas mal realizadas

Condiciones:

Si no hay facturas mal hechas para un rubro y mes, se debe retornar 0.
Solo considerar el año 2011.*/

SELECT  p.prod_rubro, 
        MONTH(F1.fact_fecha), 
        ISNULL(
                (SELECT COUNT(DISTINCT prod_rubro) FROM Item_Factura I
                    LEFT JOIN factura F
                        ON F.fact_tipo = I.item_tipo AND F.fact_sucursal = I.item_sucursal AND F.fact_numero = I.item_numero
                    LEFT JOIN producto p2
                        ON I.item_producto = p2.prod_codigo
                    WHERE YEAR(F.fact_fecha) = 2011 AND p.prod_rubro = p2.prod_rubro AND MONTH(F1.fact_fecha) = MONTH(F.fact_fecha)
                    GROUP BY F.fact_tipo, F.fact_sucursal, F.fact_numero
                    HAVING COUNT(DISTINCT p2.prod_rubro) > 1
                    )
                    , 0
                )  
FROM Item_Factura
LEFT JOIN factura F1 ON F1.fact_tipo = item_tipo AND F1.fact_sucursal = item_sucursal AND F1.fact_numero = item_numero
LEFT JOIN producto p ON item_producto = p.prod_codigo
WHERE YEAR(F1.fact_fecha)=2011
GROUP BY p.prod_rubro, MONTH(F1.fact_fecha)
