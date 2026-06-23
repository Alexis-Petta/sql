/*
-------------------------------------------------------------------
CREATE VIEW nombre_vista
AS
SELECT columna1, columna2, columna3
FROM Tabla
WHERE condicion;
-------------------------------------------------------------------
CREATE FUNCTION nombre (@param tipo)
RETURNS tipo
AS
BEGIN
    DECLARE variables

    SELECT variables = columnas
    FROM tabla
    WHERE ...

    IF condicion
        RETURN algo

    RETURN otra_cosa
END
-------------------------------------------------------------------
CREATE PROCEDURE nombre_procedure
    @parametro1 TIPO,
    @parametro2 TIPO
AS
BEGIN
    instrucciones;
END;
-------------------------------------------------------------------
CREATE TRIGGER nombre_trigger
ON Tabla
AFTER INSERT
AS
BEGIN
    instrucciones;
END;
-------------------------------------------------------------------
CREATE TRIGGER nombre_trigger
ON Tabla
AFTER INSERT
AS
BEGIN
    SELECT *
    FROM inserted;
END;
-------------------------------------------------------------------
CREATE TRIGGER nombre_trigger
ON Tabla
AFTER DELETE
AS
BEGIN
    SELECT *
    FROM deleted;
END;
-------------------------------------------------------------------
CREATE TRIGGER nombre_trigger
ON Tabla
AFTER UPDATE
AS
BEGIN
    SELECT *
    FROM deleted;

    SELECT *
    FROM inserted;
END;
-------------------------------------------------------------------

*/

/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--21

Desarrolle el/los elementos de base de datos necesarios para que se cumpla automáticamente la regla de que una factura no puede contener productos de diferentes familias.

Condiciones:

En caso de que una factura contenga productos de diferentes familias, no debe grabarse esa factura.
Debe emitirse un error en pantalla.*/

/*CREATE TRIGGER trg_factura_misma_familia
ON Item_Factura
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted INS
        JOIN Item_Factura I
            ON I.item_tipo = INS.item_tipo
           AND I.item_sucursal = INS.item_sucursal
           AND I.item_numero = INS.item_numero
        JOIN Producto P
            ON P.prod_codigo = I.item_producto
        GROUP BY
            INS.item_tipo,
            INS.item_sucursal,
            INS.item_numero
        HAVING COUNT(DISTINCT P.prod_familia) > 1
    )
    BEGIN
        RAISERROR('La factura no puede contener productos de diferentes familias', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;*/

--------------------------------------------------------------------------------------------------------------------------------------
/*

Ejercicio 2 — T-SQL

Ejercicio 20 de T-SQL

Crear el/los objetos necesarios para mantener actualizadas las comisiones del vendedor.

El cálculo de la comisión está dado por:

5% de la venta total efectuada por ese vendedor en ese mes.
Más un 3% adicional en caso de que ese vendedor haya vendido por lo menos 50 productos distintos en el mes.

*/
--------------------------------------------------------------------------------------------------------------------------------------
/*
CREATE FUNCTION func_venta_total_el_mes (@fecha smalldatetime, @empleado NUMERIC(6))
RETURNS DECIMAL(12,2)
AS
BEGIN
RETURN (
        SELECT COUNT(DISTINCT fact_numero)*5/100 FROM Factura 
        WHERE fact_vendedor = @empleado AND YEAR(fact_fecha) = YEAR(@fecha) AND MONTH(@fecha) = MONTH(fact_fecha)
       )
END


CREATE FUNCTION bonificacion_productos (@fecha smalldatetime, @empleado NUMERIC(6))
RETURNS DECIMAL(12,2)
AS
BEGIN
RETURN (
        SELECT 3 FROM Factura 
        LEFT JOIN Item_Factura ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
        WHERE fact_vendedor = @empleado AND YEAR(fact_fecha) = YEAR(@fecha) AND MONTH(@fecha) = MONTH(fact_fecha)
        HAVING count(DISTINCT item_producto)>50
       )
END

CREATE TRIGGER trig_actualizar_comision
ON factura
AFTER insert
AS
BEGIN

DECLARE @empleado char(6)
SET @empleado = (SELECT i.fact_vendedor FROM INSERTED i)

DECLARE @fecha smalldatetime
SET @fecha = (SELECT i.fact_fecha FROM INSERTED i)

UPDATE empleado
SET empl_comision = func_venta_total_el_mes(@fecha, @empleado) + bonificacion_productos(@fecha, @empleado)
WHERE empl_codigo = @empleado
END
*/--------------------------------------------------------------------------------------------------------------------------------------

--23
/*
Desarrolle el/los elementos de base de datos necesarios para que, ante una venta, se controle automáticamente que en una misma factura no puedan venderse más de dos productos con composición.

Condición:

Si una factura contiene más de dos productos con composición, deberá rechazarse la factura.
*/

/*

CREATE TRIGGER trg_no_mas_de_dos_productos_compuestos
ON Item_Factura
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted INS
        JOIN Item_Factura I
            ON I.item_tipo = INS.item_tipo
           AND I.item_sucursal = INS.item_sucursal
           AND I.item_numero = INS.item_numero
        JOIN Composicion C
            ON C.comp_producto = I.item_producto
        GROUP BY
            INS.item_tipo,
            INS.item_sucursal,
            INS.item_numero
        HAVING COUNT(DISTINCT I.item_producto) > 2
    )
    BEGIN
        RAISERROR('La factura no puede contener mas de dos productos con composicion', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

*/

/*
Ejercicio 2 — T-SQL

Ejercicio 30 de T-SQL

Agregar el/los objetos necesarios para crear una regla por la cual un cliente no pueda comprar más de 100 unidades en el mes de ningún producto.

Condiciones:

Si esto ocurre, no se deberá ingresar la operación.
Se deberá emitir el mensaje:
Se ha superado el límite máximo de compra de un producto
Se sabe que esta regla actualmente se cumple.
Se sabe que las facturas no pueden ser modificadas.
*/
/*
CREATE TRIGGER limite_compra 
ON Item_Factura
AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted INS
        JOIN Factura F_INS
            ON F_INS.fact_tipo = INS.item_tipo
           AND F_INS.fact_sucursal = INS.item_sucursal
           AND F_INS.fact_numero = INS.item_numero
        JOIN Factura F
            ON F.fact_cliente = F_INS.fact_cliente
           AND YEAR(F.fact_fecha) = YEAR(F_INS.fact_fecha)
           AND MONTH(F.fact_fecha) = MONTH(F_INS.fact_fecha)
        JOIN Item_Factura I
            ON I.item_tipo = F.fact_tipo
           AND I.item_sucursal = F.fact_sucursal
           AND I.item_numero = F.fact_numero
           AND I.item_producto = INS.item_producto
        GROUP BY
            F_INS.fact_cliente,
            INS.item_producto,
            YEAR(F_INS.fact_fecha),
            MONTH(F_INS.fact_fecha)
        HAVING SUM(I.item_cantidad) > 100
    )
    BEGIN
        RAISERROR('Se ha superado el límite máximo de compra de un producto', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;*/

--26

/*

Desarrolle el/los elementos de base de datos necesarios para que se cumpla automáticamente la regla de que una factura no puede contener productos que sean componentes de otros productos.

Condiciones:

Si esto ocurre, no debe grabarse esa factura.
Debe emitirse un error en pantalla.

Pista mínima: si la regla habla de productos dentro de una factura, pensá primero en Item_Factura, no en Factura.

*/

CREATE TRIGGER no_productos_compuestos_con_productos
ON item_factura
AFTER insert, update
AS
BEGIN

IF EXISTS (
        SELECT 1
        FROM inserted INS
        LEFT JOIN item_factura i
            ON i.item_sucursal = ins.item_sucursal AND i.item_numero = ins.item_numero AND i.item_tipo = ins.item_tipo
        LEFT JOIN producto p
            ON i.item_producto = p.prod_codigo
        LEFT JOIN Composicion c
            ON c.comp_producto = ins.item_producto
        WHERE p.prod_codigo = c.comp_componente
    )
    BEGIN
        RAISERROR('Existe un producto que matchea con un componente de un producto compuesto', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

END

