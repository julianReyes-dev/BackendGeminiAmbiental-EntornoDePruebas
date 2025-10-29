-- Crear base de datos de pruebas
DROP DATABASE IF EXISTS gemini_ambiental_TEST;
CREATE DATABASE gemini_ambiental_TEST;
USE gemini_ambiental_TEST;

-- =================================================================
-- TABLAS SIN DEPENDENCIAS EXTERNAS (O CON AUTOREFERENCIAS)
-- =================================================================

-- Tabla para almacenar direcciones (ej: país, ciudad, zona)
CREATE TABLE Direccion (
    ID_direccion VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion_adicional VARCHAR(255),
    depende_de VARCHAR(36),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (depende_de) REFERENCES Direccion(ID_direccion) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para categorías de servicios (ej: Fumigación, Desmonte, Control de Plagas)
CREATE TABLE Categoria_servicio (
    ID_categoria_servicio VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para categorías de productos (ej: Insecticidas, Herbicidas, Equipo de Protección)
CREATE TABLE Categoria_producto (
    ID_categoria_producto VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =================================================================
-- TABLAS CON DEPENDENCIAS DE NIVEL 1
-- =================================================================

-- Tabla para cargos o especialidades de los EMPLEADOS o CLIENTES (ej: Fumigador experto, Biólogo, Técnico de campo. Persona natural, juridica, etc)
CREATE TABLE Cargo_Especialidad (
    ID_cargo_especialidad VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    ID_categoria_servicio VARCHAR(36),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (ID_categoria_servicio) REFERENCES Categoria_servicio(ID_categoria_servicio) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para los tipos de servicio ofrecidos (ej: Machetear al Diablo en el monte, Fumigación, Asesinato agrabado de ratas)
CREATE TABLE Tipo_servicio (
    ID_tipo_servicio VARCHAR(36) PRIMARY KEY,
    nombre_servicio VARCHAR(255) NOT NULL,
    descripcion TEXT,
    costo DECIMAL(12, 2) NOT NULL,
    frecuencia VARCHAR(100),
    duracion VARCHAR(100),
    estado ENUM('Activo', 'Inactivo', 'En revision') NOT NULL DEFAULT 'Activo',
    ID_categoria_servicio VARCHAR(36) NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (ID_categoria_servicio) REFERENCES Categoria_servicio(ID_categoria_servicio) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para los productos en inventario (Machete mítico del abuelo, Matarratas mickey, Fumigadores xd)
CREATE TABLE Producto (
    ID_producto VARCHAR(36) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio_actual DECIMAL(12, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    unidad_medida VARCHAR(50),
    ID_categoria_producto VARCHAR(36),
    lote VARCHAR(50),
    proveedor VARCHAR(255),
    observaciones TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (ID_categoria_producto) REFERENCES Categoria_producto(ID_categoria_producto) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla central para personas (clientes y empleados)
CREATE TABLE Persona (
    DNI VARCHAR(20) PRIMARY KEY,
    tipo_dni VARCHAR(50) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(255) UNIQUE,
    rol VARCHAR(50) NOT NULL, -- ej: 'Cliente', 'Empleado'
    tipo_persona ENUM('Natural', 'Juridica') NOT NULL DEFAULT 'Natural',
    representante_legal VARCHAR(20) NULL,
    nit VARCHAR(20) NULL,
    ID_direccion VARCHAR(36),
    ID_cargo_especialidad VARCHAR(36),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (ID_direccion) REFERENCES Direccion(ID_direccion) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_cargo_especialidad) REFERENCES Cargo_Especialidad(ID_cargo_especialidad) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =================================================================
-- TABLAS CON DEPENDENCIAS DE NIVEL 2
-- =================================================================

-- Tabla para las cotizaciones solicitadas por los clientes
CREATE TABLE Cotizacion (
    ID_cotizacion VARCHAR(36) PRIMARY KEY,
    DNI_cliente VARCHAR(20) NOT NULL,
    DNI_empleado VARCHAR(20),
    estado ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Finalizada') NOT NULL DEFAULT 'Pendiente',
    fecha_solicitud DATETIME NOT NULL,
    fecha_preferida DATE,
    fecha_respuesta DATETIME,
    prioridad VARCHAR(50),
    descripcion_problema TEXT,
    notas_internas TEXT,
    costo_total_cotizacion DECIMAL(12, 2),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (DNI_cliente) REFERENCES Persona(DNI) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (DNI_empleado) REFERENCES Persona(DNI) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para las facturas generadas
CREATE TABLE Factura (
    ID_factura VARCHAR(36) PRIMARY KEY,
    DNI_cliente VARCHAR(20) NOT NULL,
    fecha_emision DATE NOT NULL,
    monto_total DECIMAL(12, 2) NOT NULL,
    estado ENUM('Pendiente', 'Pagada', 'Vencida', 'Rechazada') NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT,
    tipo_factura ENUM('Simple', 'Con Cotizacion') DEFAULT 'Simple',
    ID_cotizacion VARCHAR(36) NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (DNI_cliente) REFERENCES Persona(DNI) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_cotizacion) REFERENCES Cotizacion(ID_cotizacion) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tabla para registrar los servicios agendados
CREATE TABLE Servicio (
    ID_servicio VARCHAR(36) PRIMARY KEY,
    ID_cotizacion VARCHAR(36), -- Un servicio sale de una cotización aprobada
    DNI_empleado_asignado VARCHAR(20),
    DNI_cliente VARCHAR(20),
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    duracion_estimada VARCHAR(100),
    observaciones TEXT,
    prioridad VARCHAR(50),
    estado ENUM('Programado', 'En Progreso', 'Completado', 'Cancelado') NOT NULL DEFAULT 'Programado',
    activo BOOLEAN DEFAULT TRUE,
    servicio_sin_cotizacion BOOLEAN DEFAULT FALSE,
    id_tipo_servicio VARCHAR(36),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (ID_cotizacion) REFERENCES Cotizacion(ID_cotizacion) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (DNI_empleado_asignado) REFERENCES Persona(DNI) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (DNI_cliente) REFERENCES Persona(DNI) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_tipo_servicio) REFERENCES Tipo_servicio(ID_tipo_servicio) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =================================================================
-- TABLAS DE DETALLE / TABLAS INTERMEDIAS (JUNCTION TABLES)
-- =================================================================

-- Detalle de los servicios incluidos en una cotización
CREATE TABLE Detalle_Cotizacion (
    ID_detalle_cotizacion VARCHAR(36) PRIMARY KEY,
    ID_cotizacion VARCHAR(36) NOT NULL,
    ID_tipo_servicio VARCHAR(36) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(12, 2) NOT NULL,
    costos_extra DECIMAL(12, 2) DEFAULT 0,
    descripcion_costos_extra TEXT,
    subtotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (ID_cotizacion) REFERENCES Cotizacion(ID_cotizacion) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_tipo_servicio) REFERENCES Tipo_servicio(ID_tipo_servicio) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Detalle de los servicios incluidos en una factura
CREATE TABLE detalle_factura (
    ID_factura VARCHAR(36) NOT NULL,
    ID_servicio VARCHAR(36) NOT NULL,
    precio_unitario DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (ID_factura, ID_servicio),
    FOREIGN KEY (ID_factura) REFERENCES Factura(ID_factura) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_servicio) REFERENCES Servicio(ID_servicio) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Relaciona los productos utilizados en un servicio específico
CREATE TABLE servicio_producto (
    ID_servicio VARCHAR(36) NOT NULL,
    ID_producto VARCHAR(36) NOT NULL,
    cantidad INT NOT NULL,
    precio_actual DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (ID_servicio, ID_producto),
    FOREIGN KEY (ID_servicio) REFERENCES Servicio(ID_servicio) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_producto) REFERENCES Producto(ID_producto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =================================================================
-- ÍNDICES ADICIONALES PARA MEJORAR RENDIMIENTO
-- =================================================================

CREATE INDEX idx_persona_nombre ON Persona(nombre);
CREATE INDEX idx_persona_correo ON Persona(correo);
CREATE INDEX idx_cotizacion_fecha ON Cotizacion(fecha_solicitud);
CREATE INDEX idx_servicio_fecha ON Servicio(fecha);
CREATE INDEX idx_factura_fecha ON Factura(fecha_emision);
CREATE INDEX idx_producto_nombre ON Producto(nombre);
CREATE INDEX idx_persona_tipo_documento ON Persona(tipo_persona, DNI);
CREATE INDEX idx_servicio_fecha_estado ON Servicio(fecha, estado);
CREATE INDEX idx_servicio_fecha_empleado ON Servicio(fecha, DNI_empleado_asignado);
CREATE INDEX idx_factura_tipo_fecha ON Factura(tipo_factura, fecha_emision);

-- =================================================================
-- COMENTARIOS EN LAS TABLAS
-- =================================================================

ALTER TABLE Direccion COMMENT = 'Almacena direcciones con estructura jerárquica (país > estado > ciudad)';
ALTER TABLE Categoria_servicio COMMENT = 'Agrupa los tipos de servicio (ej: Fumigación, Desmonte, Asesorías)';
ALTER TABLE Categoria_producto COMMENT = 'Categorías de productos en inventario';
ALTER TABLE Cargo_Especialidad COMMENT = 'Cargos y especialidades de los empleados (ej: Fumigador, Biólogo)';
ALTER TABLE Tipo_servicio COMMENT = 'Tipos específicos de servicios disponibles que se pueden cotizar';
ALTER TABLE Producto COMMENT = 'Inventario de productos y repuestos';
ALTER TABLE Persona COMMENT = 'Información de clientes y empleados del sistema';
ALTER TABLE Cotizacion COMMENT = 'Cotizaciones solicitadas por los clientes';
ALTER TABLE Factura COMMENT = 'Facturas generadas por servicios realizados';
ALTER TABLE Servicio COMMENT = 'Servicios programados y ejecutados';
ALTER TABLE Detalle_Cotizacion COMMENT = 'Detalle de servicios incluidos en cada cotización';
ALTER TABLE detalle_factura COMMENT = 'Detalle de servicios facturados';
ALTER TABLE servicio_producto COMMENT = 'Productos utilizados en cada servicio específico';

-- =================================================================
-- TRIGGERS PARA VALIDACIONES
-- =================================================================

DELIMITER $$

-- Trigger para validar tipo de persona
CREATE TRIGGER tr_validar_tipo_persona
    BEFORE INSERT ON Persona
    FOR EACH ROW
BEGIN
    IF NEW.tipo_persona = 'Juridica' THEN
        -- Para persona jurídica, el NIT es obligatorio
        IF NEW.nit IS NULL OR NEW.nit = '' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Para persona jurídica, el NIT es obligatorio';
        END IF;
        -- El DNI original se convierte en el NIT para jurídicas
        SET NEW.DNI = NEW.nit;
    ELSE
        -- Para persona natural, el NIT debe ser nulo
        IF NEW.nit IS NOT NULL AND NEW.nit != '' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La persona natural no debe tener NIT';
        END IF;
    END IF;
END$$

CREATE TRIGGER tr_validar_tipo_persona_update
    BEFORE UPDATE ON Persona
    FOR EACH ROW
BEGIN
    IF NEW.tipo_persona = 'Juridica' THEN
        -- Para persona jurídica, el NIT es obligatorio
        IF NEW.nit IS NULL OR NEW.nit = '' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Para persona jurídica, el NIT es obligatorio';
        END IF;
        -- El DNI original se convierte en el NIT para jurídicas
        SET NEW.DNI = NEW.nit;
    ELSE
        -- Para persona natural, el NIT debe ser nulo
        IF NEW.nit IS NOT NULL AND NEW.nit != '' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La persona natural no debe tener NIT';
        END IF;
    END IF;
END$$

-- Trigger para validar fechas en Servicio
CREATE TRIGGER tr_validar_fecha_servicio
    BEFORE INSERT ON Servicio
    FOR EACH ROW
BEGIN
    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede programar un servicio en una fecha pasada';
    END IF;
END$$

CREATE TRIGGER tr_validar_fecha_servicio_update
    BEFORE UPDATE ON Servicio
    FOR EACH ROW
BEGIN
    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede programar un servicio en una fecha pasada';
    END IF;
END$$

-- Trigger para prevenir eliminación de servicios asignados
CREATE TRIGGER tr_prevent_servicio_delete
    BEFORE DELETE ON Servicio
    FOR EACH ROW
BEGIN
    -- Verificar si el servicio está en una factura
    DECLARE relacionado_count INT DEFAULT 0;

    SELECT COUNT(*) INTO relacionado_count
    FROM detalle_factura
    WHERE ID_servicio = OLD.ID_servicio;

    IF relacionado_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el servicio porque está asignado a una factura';
    END IF;

    -- Verificar si el servicio tiene productos asociados
    SELECT COUNT(*) INTO relacionado_count
    FROM servicio_producto
    WHERE ID_servicio = OLD.ID_servicio;

    IF relacionado_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el servicio porque tiene productos asociados';
    END IF;

    -- Nueva condición: Verificar si el servicio está "agendado" (no cancelado ni completado)
    -- Asumiendo que 'Programado' y 'En Progreso' significan que está agendado
    -- Ajusta los estados según tu lógica de negocio
    IF OLD.estado IN ('Programado', 'En Progreso') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el servicio porque está agendado y su estado es Activo.';
    END IF;

END$$
DELIMITER ;

-- =================================================================
-- VISTAS
-- =================================================================

CREATE VIEW vista_agenda AS
SELECT
    s.ID_servicio,
    s.fecha,
    s.hora,
    s.estado,
    s.prioridad,
    s.observaciones,
    c.ID_cotizacion,
    CONCAT(p.nombre, ' - ', p.DNI) AS cliente,
    CONCAT(e.nombre, ' - ', e.DNI) AS empleado,
    (SELECT COUNT(*) FROM Servicio WHERE fecha = s.fecha) AS servicios_dia
FROM Servicio s
LEFT JOIN Cotizacion c ON s.ID_cotizacion = c.ID_cotizacion
LEFT JOIN Persona p ON c.DNI_cliente = p.DNI
LEFT JOIN Persona e ON s.DNI_empleado_asignado = e.DNI
ORDER BY s.fecha, s.hora;

-- =================================================================
-- CREACIÓN DE USUARIOS
-- =================================================================

CREATE USER IF NOT EXISTS 'gemini_app'@'localhost' IDENTIFIED BY 'G3m1n1@Amb13nt4l2025';
GRANT ALL PRIVILEGES ON gemini_ambiental_DB2.* TO 'gemini_app'@'localhost';
FLUSH PRIVILEGES;

-- =================================================================
-- DATOS DE PRUEBA
-- =================================================================

-- Insertar direcciones de prueba
INSERT INTO Direccion (ID_direccion, nombre, descripcion_adicional)
VALUES
    (UUID(), 'Calle 123', 'Bogotá'),
    (UUID(), 'Carrera 45', 'Medellín'),
    (UUID(), 'Avenida 7', 'Tunja');

-- Insertar categorías de servicio
INSERT INTO Categoria_servicio (ID_categoria_servicio, nombre, descripcion)
VALUES
    (UUID(), 'Control de Plagas', 'Servicios de fumigación y control de plagas urbanas'),
    (UUID(), 'Limpieza de Tanques', 'Limpieza y desinfección de tanques de agua potable'),
    (UUID(), 'Certificados Sanitarios', 'Emisión de certificados y documentación sanitaria'),
    (UUID(), 'Mantenimiento', 'Servicios de mantenimiento preventivo y correctivo'),
    (UUID(), 'Inspección', 'Inspecciones sanitarias y de calidad ambiental'),
    (UUID(), 'Fumigación', 'Servicios especializados de fumigación'),
    (UUID(), 'Limpieza General', 'Servicios de limpieza y desinfección general');

-- Insertar categorías de producto
INSERT INTO Categoria_producto (ID_categoria_producto, nombre, descripcion)
VALUES
    (UUID(), 'Insecticidas', 'Productos para control de insectos'),
    (UUID(), 'Herbicidas', 'Productos para control de malezas'),
    (UUID(), 'Equipo de Protección', 'Elementos de protección personal'),
    (UUID(), 'Herramientas', 'Herramientas para servicios'),
    (UUID(), 'Materiales de limpieza', 'Productos de limpieza y desinfección');

-- Insertar cargos de prueba
INSERT INTO Cargo_Especialidad (ID_cargo_especialidad, nombre, descripcion, ID_categoria_servicio)
VALUES
    (UUID(), 'Servicios Varios', 'Personal de apoyo', NULL),
    (UUID(), 'Ingeniero Ambiental', 'Especialista en gestión ambiental', NULL),
    (UUID(), 'Administrador', 'Gestión de proyectos y personal', NULL),
    (UUID(), 'Fumigador', 'Especialista en control de plagas', (SELECT ID_categoria_servicio FROM Categoria_servicio WHERE nombre = 'Fumigación'));

-- Insertar tipos de servicio de prueba
INSERT INTO Tipo_servicio (ID_tipo_servicio, nombre_servicio, descripcion, costo, frecuencia, duracion, estado, ID_categoria_servicio)
VALUES
    (UUID(), 'Fumigación General', 'Fumigación de todo tipo de plagas', 150000.00, 'Unica', '2 horas', 'Activo', (SELECT ID_categoria_servicio FROM Categoria_servicio WHERE nombre = 'Fumigación')),
    (UUID(), 'Limpieza de Tanque', 'Limpieza y desinfección de tanque de agua', 200000.00, 'Mensual', '4 horas', 'Activo', (SELECT ID_categoria_servicio FROM Categoria_servicio WHERE nombre = 'Limpieza de Tanques')),
    (UUID(), 'Inspección Sanitaria', 'Inspección de condiciones sanitarias', 100000.00, 'Mensual', '1 hora', 'Activo', (SELECT ID_categoria_servicio FROM Categoria_servicio WHERE nombre = 'Inspección'));

-- Insertar productos de prueba
INSERT INTO Producto (ID_producto, nombre, precio_actual, stock, unidad_medida, ID_categoria_producto, lote, proveedor, observaciones)
VALUES
    (UUID(), 'Matarratas Mickey', 45000.00, 50, 'unidad', (SELECT ID_categoria_producto FROM Categoria_producto WHERE nombre = 'Insecticidas'), 'L001', 'Química Andina', 'Producto de alta calidad'),
    (UUID(), 'Guantes de Protección', 15000.00, 100, 'par', (SELECT ID_categoria_producto FROM Categoria_producto WHERE nombre = 'Equipo de Protección'), 'L002', 'BioSafe', 'Guantes resistentes'),
    (UUID(), 'Desinfectante', 25000.00, 30, 'litro', (SELECT ID_categoria_producto FROM Categoria_producto WHERE nombre = 'Materiales de limpieza'), 'L003', 'EcoPlag', 'Desinfectante ecológico');

-- Insertar personas de prueba
INSERT INTO Persona (DNI, tipo_dni, nombre, telefono, correo, rol, tipo_persona, representante_legal, nit, ID_direccion, ID_cargo_especialidad)
VALUES
    ('123456789', 'CC', 'Juan Pérez', '3001234567', 'juan.perez@email.com', 'Cliente', 'Natural', NULL, NULL, (SELECT ID_direccion FROM Direccion LIMIT 1), NULL),
    ('987654321', 'CC', 'María López', '3009876543', 'maria.lopez@email.com', 'Empleado', 'Natural', NULL, NULL, (SELECT ID_direccion FROM Direccion LIMIT 1), (SELECT ID_cargo_especialidad FROM Cargo_Especialidad WHERE nombre = 'Fumigador')),
    ('111111111', 'NIT', 'Empresa Ambiental S.A.S', '3001111111', 'contacto@empresa.com', 'Cliente', 'Juridica', 'Carlos Ruiz', '111111111', (SELECT ID_direccion FROM Direccion LIMIT 1), NULL);

-- Insertar cotizaciones de prueba
INSERT INTO Cotizacion (ID_cotizacion, DNI_cliente, DNI_empleado, estado, fecha_solicitud, descripcion_problema)
VALUES
    (UUID(), '123456789', '987654321', 'Aprobada', NOW(), 'Plagas en la cocina'),
    (UUID(), '111111111', '987654321', 'Pendiente', NOW(), 'Inspección general de planta');

-- Insertar facturas de prueba
INSERT INTO Factura (ID_factura, DNI_cliente, fecha_emision, monto_total, estado)
VALUES
    (UUID(), '123456789', CURDATE(), 150000.00, 'Pagada'),
    (UUID(), '111111111', DATE_ADD(CURDATE(), INTERVAL 15 DAY), 200000.00, 'Pendiente');

-- Insertar servicios de prueba
INSERT INTO Servicio (ID_servicio, ID_cotizacion, DNI_empleado_asignado, DNI_cliente, fecha, hora, estado, id_tipo_servicio)
VALUES
    (UUID(), (SELECT ID_cotizacion FROM Cotizacion LIMIT 1), '987654321', '123456789', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00:00', 'Programado', (SELECT ID_tipo_servicio FROM Tipo_servicio WHERE nombre_servicio = 'Fumigación General')),
    (UUID(), (SELECT ID_cotizacion FROM Cotizacion LIMIT 1 OFFSET 1), '987654321', '111111111', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '14:00:00', 'Programado', (SELECT ID_tipo_servicio FROM Tipo_servicio WHERE nombre_servicio = 'Inspección Sanitaria'));

SELECT '✅ Base de datos Gemini Ambiental (DB2) creada y configurada completamente.' AS mensaje;

SET SQL_SAFE_UPDATES = 0;
-- Corregir 'Activo' a 'ACTIVO'
UPDATE tipo_servicio 
SET estado = 'ACTIVO' 
WHERE estado = 'Activo';

-- Corregir 'Inactivo' a 'INACTIVO'
UPDATE tipo_servicio 
SET estado = 'INACTIVO' 
WHERE estado = 'Inactivo';

-- Corregir 'En Revision' a 'EN_REVISION'
-- (Asegúrate de que el valor en la BD sea exactamente 'En Revision')
UPDATE tipo_servicio 
SET estado = 'EN_REVISION' 
WHERE estado = 'En Revision';

SELECT DISTINCT estado FROM tipo_servicio;

-- 1. Crear una columna temporal
ALTER TABLE tipo_servicio ADD COLUMN estado_temp VARCHAR(50);

-- 2. Copiar los datos desde la columna ENUM a la VARCHAR
UPDATE tipo_servicio SET estado_temp = estado;

-- 3. Eliminar la columna ENUM original
ALTER TABLE tipo_servicio DROP COLUMN estado;

-- 4. Renombrar la columna temporal
ALTER TABLE tipo_servicio CHANGE estado_temp estado VARCHAR(50);

-- 5. Asegurar que no sea NULL y tenga un valor por defecto si es necesario
ALTER TABLE tipo_servicio MODIFY COLUMN estado VARCHAR(50) NOT NULL DEFAULT 'ACTIVO';

ALTER TABLE tipo_servicio 
ADD COLUMN icono VARCHAR(50) NULL;

DELETE FROM servicio WHERE id_servicio="ce3f471f-5ef1-422c-add6-e7c93134f83f";
select * from servicio;

DELETE FROM servicio 
WHERE dni_cliente IS NULL 
   OR dni_empleado_asignado IS NULL 
   OR id_tipo_servicio IS NULL;


INSERT INTO Servicio (ID_servicio, ID_cotizacion, DNI_empleado_asignado, DNI_cliente, fecha, hora, estado, id_tipo_servicio)
VALUES
    (UUID(), (SELECT ID_cotizacion FROM Cotizacion LIMIT 1), '987654321', '123456789', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00:00', 'Programado', (SELECT ID_tipo_servicio FROM Tipo_servicio WHERE nombre_servicio = 'Fumigación General')),
    (UUID(), (SELECT ID_cotizacion FROM Cotizacion LIMIT 1 OFFSET 1), '987654321', '111111111', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '14:00:00', 'Programado', (SELECT ID_tipo_servicio FROM Tipo_servicio WHERE nombre_servicio = 'Inspección Sanitaria'));

-- Ver cuántos servicios tienen datos NULL
DELETE FROM servicio 
WHERE dni_cliente IS NULL 
   OR dni_empleado_asignado IS NULL 
   OR id_tipo_servicio IS NULL;

-- Crear usuario específico para pruebas
CREATE USER IF NOT EXISTS 'gemini_test'@'localhost' IDENTIFIED BY 'T3st_G3m1n1@2025';
GRANT ALL PRIVILEGES ON gemini_ambiental_TEST.* TO 'gemini_test'@'localhost';
FLUSH PRIVILEGES;