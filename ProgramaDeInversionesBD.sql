CREATE DATABASE programa_inversiones;

CREATE TABLE Entidad (
    ID_Entidad SERIAL PRIMARY KEY,
    Rut VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,
    TipoEntidad VARCHAR(50) NOT NULL, -- Por ejemplo: Banco, Corredora, Compañía de Seguros
    Contacto VARCHAR(100),
    Email VARCHAR(100),
    FonoFijo VARCHAR(15),
    FonoMovil VARCHAR(15)
);

CREATE TABLE EntidadComercial (
    ID_Entidad SERIAL PRIMARY KEY,
    Rut VARCHAR(20) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,
    TipoEntidad VARCHAR(50) NOT NULL -- Por ejemplo: Cliente, Empresa
);

CREATE TABLE Facturas (
    NumeroFactura SERIAL PRIMARY KEY,
    ID_Corredora INT NOT NULL REFERENCES Entidad(ID_Entidad),
    Fecha DATE NOT NULL,
    Tipo VARCHAR(50) NOT NULL, -- Compra o Venta
    Cantidad INT NOT NULL,
    Valor DECIMAL(15, 2) NOT NULL,
    SubTotal DECIMAL(15, 2) NOT NULL,
    Comision DECIMAL(15, 2),
    Gasto DECIMAL(15, 2),
    AdjuntoFactura VARCHAR(255),
    ID_TipoInversion INT NOT NULL REFERENCES TipoInversion(ID)
);

CREATE TABLE BoletaGarantia (
    Numero SERIAL PRIMARY KEY,
    ID_Banco INT NOT NULL REFERENCES Entidad(ID_Entidad),
    ID_Cliente INT NOT NULL REFERENCES EntidadComercial(ID_Entidad),
    Glosa TEXT,
    Vencimiento DATE NOT NULL,
    Moneda VARCHAR(10) NOT NULL, -- ISO 4217 (USD, CLP, etc.)
    Monto DECIMAL(15, 2) NOT NULL
);

CREATE TABLE FondosMutuos (
    ID_Fondo SERIAL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    MontoInvertido DECIMAL(15, 2) NOT NULL,
    Rentabilidad DECIMAL(5, 2),
    MontoFinal DECIMAL(15, 2),
    ID_Entidad INT NOT NULL REFERENCES Entidad(ID_Entidad),
    Comprobante VARCHAR(255)
);

CREATE TABLE Polizas (
    Numero SERIAL PRIMARY KEY,
    TipoAsegurado VARCHAR(50) NOT NULL, -- Cliente o Empresa
    FechaInicio DATE NOT NULL,
    FechaTermino DATE NOT NULL,
    Monto DECIMAL(15, 2) NOT NULL,
    AdjuntoPoliza VARCHAR(255)
);

CREATE TABLE TipoInversion (
    ID SERIAL PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL -- Compra, Venta, etc.
);

CREATE TABLE Accion (
    ID_Accion SERIAL PRIMARY KEY,
    Ticker VARCHAR(15) NOT NULL UNIQUE,
    Nombre VARCHAR(100) NOT NULL,
    Mercado VARCHAR(50),
    Sector VARCHAR(50)
);

CREATE TABLE Dividendos (
    ID_Dividendo SERIAL PRIMARY KEY,
    ID_Accion INT NOT NULL REFERENCES Accion(ID_Accion),
    Monto DECIMAL(15, 2) NOT NULL,
    Fecha DATE NOT NULL
);

CREATE TABLE DepositoAPlazo (
    ID_Deposito SERIAL PRIMARY KEY,
    ID_Empresa INT NOT NULL REFERENCES EntidadComercial(ID_Entidad),
    ID_Banco INT NOT NULL REFERENCES Entidad(ID_Entidad), -- Opcional, si el banco es importante
    FechaInicio DATE NOT NULL,
    FechaTermino DATE NOT NULL,
    Moneda VARCHAR(10) NOT NULL, -- ISO 4217 (CLP, USD, etc.)
    MontoInicial DECIMAL(15, 2) NOT NULL,
    MontoFinal DECIMAL(15, 2),
    Comprobante VARCHAR(255)
);

ALTER TABLE Facturas
ADD COLUMN Rut VARCHAR(20);

UPDATE Facturas
SET Rut = (SELECT Rut FROM Entidad WHERE Entidad.ID_Entidad = Facturas.ID_Corredora);

ALTER TABLE Facturas
ADD COLUMN PrecioUnitario DECIMAL(15, 2);

ALTER TABLE Facturas
ADD COLUMN NombreActivo VARCHAR(100) NOT NULL;

INSERT INTO TipoInversion (Nombre) VALUES ('Compra'), ('Venta');

CREATE TABLE Usuarios (
    ID SERIAL PRIMARY KEY,
    NombreUsuario VARCHAR(50) UNIQUE NOT NULL,
    Contraseña VARCHAR(255) NOT NULL
);

ALTER TABLE DepositoAPlazo ADD COLUMN TipoDeposito VARCHAR(20);

ALTER TABLE DepositoAPlazo ADD COLUMN TipoDeposito VARCHAR(20);

ALTER TABLE FondosMutuos
ADD COLUMN TipoRiesgo VARCHAR(20);

ALTER TABLE FondosMutuos
ADD COLUMN FechaInicio DATE,
ADD COLUMN FechaTermino DATE;

ALTER TABLE FondosMutuos
ADD COLUMN ID_Banco INT REFERENCES Entidad(ID_Entidad);

ALTER TABLE FondosMutuos
DROP CONSTRAINT fondosmutuos_id_entidad_fkey;

ALTER TABLE FondosMutuos
ADD CONSTRAINT fondosmutuos_id_entidadcomercial_fkey
FOREIGN KEY (ID_Entidad) REFERENCES EntidadComercial(ID_Entidad);

-- Agregar la columna FechaEmision
ALTER TABLE BoletaGarantia
ADD COLUMN FechaEmision DATE NOT NULL;

-- Agregar la columna Estado
ALTER TABLE BoletaGarantia
ADD COLUMN Estado VARCHAR(20) NOT NULL DEFAULT 'Activa';

-- Agregar la columna ID_Beneficiario (antes llamada ID_Cliente)
ALTER TABLE BoletaGarantia
RENAME COLUMN ID_Cliente TO ID_Beneficiario;

ALTER TABLE BoletaGarantia
ADD COLUMN Documento VARCHAR(255);

ALTER TABLE DepositoAPlazo
ADD COLUMN InteresGanado DECIMAL(15, 2) DEFAULT 0.00;

ALTER TABLE DepositoAPlazo
RENAME COLUMN FechaTermino TO FechaVencimiento;

ALTER TABLE DepositoAPlazo
ADD COLUMN Plazo INT;

ALTER TABLE DepositoAPlazo
ADD COLUMN TasaInteres NUMERIC(6, 4); -- 6 dígitos, 4 decimales (para valores como 0.1700%)

ALTER TABLE DepositoAPlazo
RENAME COLUMN ID_Entidad TO ID_EntidadComercial;

ALTER TABLE DepositoAPlazo
ADD CONSTRAINT fk_deposito_id_entidadcomercial
FOREIGN KEY (ID_EntidadComercial) REFERENCES EntidadComercial(ID_Entidad);

ALTER TABLE DepositoAPlazo
ADD COLUMN ReajusteGanado NUMERIC(15, 2);

UPDATE DepositoAPlazo
SET Plazo = fechavencimiento - fechaemision;

ALTER TABLE DepositoAPlazo
ADD COLUMN CapitalRenovacion NUMERIC(15, 2),
ADD COLUMN FechaEmisionRenovacion DATE,
ADD COLUMN TasaInteresRenovacion NUMERIC(5, 2),
ADD COLUMN PlazoRenovacion INTEGER,
ADD COLUMN TasaPeriodo NUMERIC(5, 2),
ADD COLUMN FechaVencimientoRenovacion DATE,
ADD COLUMN TotalPagarRenovacion NUMERIC(15, 2);

ALTER TABLE DepositoAPlazo
ALTER COLUMN ID_Deposito TYPE BIGINT USING ID_Deposito::BIGINT;