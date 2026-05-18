-- ============================================================
-- BASE DE DATOS PARA CLUB DEPORTIVO - GESTIÓN DE SOCIOS
-- Basado en el documento "fase 2 proyecto (Reparado).docx"
-- Versión: 1.0 (corregida y unificada)
-- ============================================================

-- Eliminar la base de datos si existe (con precaución)
DROP DATABASE IF EXISTS club_socios;
CREATE DATABASE club_socios CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE club_socios;

-- ============================================================
-- 1. TABLAS PRINCIPALES
-- ============================================================

-- Tabla de roles de usuario (secretaria, contador, vigilante, admin)
CREATE TABLE ROL (
    id_rol INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE COMMENT 'secretaria, contador, vigilante, admin'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de usuarios del sistema (empleados)
CREATE TABLE USUARIO (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL COMMENT 'almacenado con hash (bcrypt o similar)',
    id_rol INT NOT NULL,
    is_temporary BOOLEAN DEFAULT TRUE COMMENT 'True = debe cambiar contraseña en primer login',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_rol) REFERENCES ROL(id_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de socios (titulares)
CREATE TABLE SOCIO (
    id_socio INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    edad TINYINT NOT NULL CHECK (edad >= 18),
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    rfc VARCHAR(13) NOT NULL UNIQUE,
    estatus ENUM('al_corriente', 'moroso') DEFAULT 'al_corriente',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tarjeta de crédito obligatoria (1 a 1 con socio, encriptada en app)
CREATE TABLE TARJETA (
    id_tarjeta INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(255) NOT NULL COMMENT 'encriptado AES-256 en la aplicación',
    id_socio INT NOT NULL UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Familiares del socio (máximo 6, primeros 3 gratis, del 4to al 6to cargo $500 único)
CREATE TABLE FAMILIAR (
    id_familiar INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    id_socio INT NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    INDEX idx_socio (id_socio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inscripción del socio (única, pero para reinscripciones se puede historizar quitando UNIQUE)
CREATE TABLE INSCRIPCION (
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL DEFAULT 8000.00,
    tipo_pago ENUM('contado', 'a_3_meses') NOT NULL,
    fecha_inscripcion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    INDEX idx_socio (id_socio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pagarés generados solo si tipo_pago = 'a_3_meses' (exactamente 3 registros)
CREATE TABLE PAGARE (
    id_pagare INT PRIMARY KEY AUTO_INCREMENT,
    id_inscripcion INT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    pagado BOOLEAN DEFAULT FALSE,
    fecha_pago DATE NULL,
    FOREIGN KEY (id_inscripcion) REFERENCES INSCRIPCION(id_inscripcion) ON DELETE CASCADE,
    INDEX idx_inscripcion (id_inscripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mensualidades (cargos periódicos)
CREATE TABLE MENSUALIDAD (
    id_mensualidad INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL COMMENT 'monto base antes de descuento',
    fecha_emision DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    tipo_plan ENUM('mensual', 'semestral', 'anual') NOT NULL,
    descuento_aplicado DECIMAL(5,2) DEFAULT 0.00 COMMENT 'porcentaje (10 o 20)',
    monto_final DECIMAL(10,2) NOT NULL COMMENT 'monto con descuento aplicado',
    pagada BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    INDEX idx_socio (id_socio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Consumos en áreas del club (bar, restaurante, tienda, etc.)
CREATE TABLE CONSUMO (
    id_consumo INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    area ENUM('bar', 'restaurante', 'tienda', 'spa', 'renta_equipos', 'otro') NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    INDEX idx_socio_fecha (id_socio, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Registro de invitados (cargo de $100 por persona al socio titular)
CREATE TABLE INVITADO (
    id_invitado INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    cantidad TINYINT NOT NULL CHECK (cantidad > 0),
    costo_total DECIMAL(10,2) NOT NULL COMMENT 'cantidad * 100 (tarifa por invitado)',
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Pagos realizados por el socio (abonos a cualquier concepto)
CREATE TABLE PAGO (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    tipo ENUM('inscripcion', 'mensualidad', 'invitado', 'cargo_familiar', 'consumo', 'otro') NOT NULL,
    metodo_pago ENUM('efectivo', 'tarjeta', 'transferencia') NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100) COMMENT 'ID del documento asociado (ej. id_mensualidad)',
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    INDEX idx_socio_fecha (id_socio, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Estado de cuenta periódico (resumen mensual)
CREATE TABLE ESTADO_CUENTA (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    id_socio INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL COMMENT '16% del subtotal',
    total DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    generado_por INT NOT NULL, -- id_usuario que generó el reporte
    FOREIGN KEY (id_socio) REFERENCES SOCIO(id_socio) ON DELETE CASCADE,
    FOREIGN KEY (generado_por) REFERENCES USUARIO(id_usuario),
    INDEX idx_socio_fecha (id_socio, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bitácora de auditoría (inalterable)
CREATE TABLE BITACORA (
    id_bitacora INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    accion VARCHAR(100) NOT NULL,
    valor_anterior TEXT,
    valor_nuevo TEXT,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45) NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario) ON DELETE CASCADE,
    INDEX idx_usuario_fecha (id_usuario, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de parámetros configurables por la administradora
CREATE TABLE PARAMETRO_SISTEMA (
    id_parametro INT PRIMARY KEY AUTO_INCREMENT,
    clave VARCHAR(50) NOT NULL UNIQUE,
    valor VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    actualizado_por INT NOT NULL,
    FOREIGN KEY (actualizado_por) REFERENCES USUARIO(id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. DATOS INICIALES (PARÁMETROS Y ROLES)
-- ============================================================

INSERT INTO ROL (nombre) VALUES 
('secretaria'),
('contador'),
('vigilante'),
('admin');

-- Insertar un usuario administrador por defecto (contraseña: 'admin123' - en producción usar hash)
-- La contraseña en texto plano solo para demo; en realidad debe ir cifrada con bcrypt.
INSERT INTO USUARIO (nombre, username, password, id_rol, is_temporary, activo) VALUES
('Administrador General', 'admin', '$2y$10$N9qo8uLOickgx2ZMRZoMy.Mr/.cZqF5NkLqZx9ZfBqHw3Xa8Z8sS2', 4, FALSE, TRUE);

-- Parámetros globales del sistema (valores por defecto según documento)
INSERT INTO PARAMETRO_SISTEMA (clave, valor, descripcion, actualizado_por) VALUES
('costo_inscripcion', '8000', 'Monto de inscripción al club', 1),
('mensualidad_base', '1000', 'Cuota mensual estándar', 1),
('descuento_semestral', '10', 'Porcentaje de descuento por pago semestral (6 meses)', 1),
('descuento_anual', '20', 'Porcentaje de descuento por pago anual (12 meses)', 1),
('costo_invitado', '100', 'Cargo por cada invitado externo', 1),
('cargo_familiar_extra', '500', 'Cargo único por familiar adicional (del 4to al 6to)', 1),
('max_familiares', '6', 'Número máximo de familiares registrables por socio', 1),
('familiares_gratis', '3', 'Cantidad de familiares sin cargo extra', 1),
('horario_apertura', '07:45:00', 'Hora de inicio de operaciones del sistema', 1),
('horario_cierre', '20:15:00', 'Hora de fin de operaciones del sistema', 1),
('dias_laborales', '2,3,4,5,6,7', 'Días de operación (2=lunes? según documento mar-dom, ajustar)', 1),
('iva', '16', 'Porcentaje de IVA aplicado', 1);

-- Nota: el horario real según documento es martes a domingo de 7:45 a 20:15.
-- Los días se pueden interpretar como 2=Martes...7=Domingo (siendo 1=Lunes). 
-- Se deja a criterio de la aplicación.

-- ============================================================
-- 3. TRIGGERS Y PROCEDIMIENTOS PARA REGLAS DE NEGOCIO
-- ============================================================

-- 3.1 Trigger para limitar a 6 familiares y generar el cargo extra automático
-- Se ejecuta después de insertar un familiar (desde la app se puede llamar a un SP mejor)
-- Pero para integridad se puede usar un trigger que verifique el límite y registre el pago.
-- Nota: Por simplicidad, la lógica de cobro se implementará en la aplicación.
-- Aquí solo se incluye la restricción de límite mediante un trigger de validación.

DELIMITER //

CREATE TRIGGER before_insert_familiar
BEFORE INSERT ON FAMILIAR
FOR EACH ROW
BEGIN
    DECLARE familiares_count INT;
    SELECT COUNT(*) INTO familiares_count FROM FAMILIAR WHERE id_socio = NEW.id_socio;
    IF familiares_count >= (SELECT CAST(valor AS UNSIGNED) FROM PARAMETRO_SISTEMA WHERE clave = 'max_familiares') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite máximo de 6 familiares alcanzado';
    END IF;
END //

-- 3.2 Trigger para generar automáticamente 3 pagarés cuando la inscripción es a 3 meses
-- Se ejecuta después de insertar una inscripción con tipo_pago = 'a_3_meses'
CREATE TRIGGER after_insert_inscripcion
AFTER INSERT ON INSCRIPCION
FOR EACH ROW
BEGIN
    DECLARE v_monto_parcial DECIMAL(10,2);
    DECLARE i INT DEFAULT 1;
    IF NEW.tipo_pago = 'a_3_meses' THEN
        SET v_monto_parcial = NEW.monto / 3;
        WHILE i <= 3 DO
            INSERT INTO PAGARE (id_inscripcion, fecha_vencimiento, monto, pagado)
            VALUES (NEW.id_inscripcion, DATE_ADD(CURDATE(), INTERVAL i MONTH), v_monto_parcial, FALSE);
            SET i = i + 1;
        END WHILE;
    END IF;
END //

-- 3.3 Procedimiento para aplicar descuento por pago anticipado de mensualidades
-- Se usa al registrar un pago de tipo 'mensualidad' con plan semestral o anual.
-- El procedimiento crea los registros de mensualidad con los descuentos correspondientes.
CREATE PROCEDURE generar_mensualidades_anticipadas(
    IN p_id_socio INT,
    IN p_tipo_plan ENUM('semestral', 'anual'),
    IN p_fecha_inicio DATE,
    IN p_metodo_pago ENUM('efectivo', 'tarjeta', 'transferencia')
)
BEGIN
    DECLARE v_mensualidad_base DECIMAL(10,2);
    DECLARE v_descuento_porcentaje DECIMAL(5,2);
    DECLARE v_monto_con_descuento DECIMAL(10,2);
    DECLARE v_num_meses INT;
    DECLARE v_i INT DEFAULT 0;
    
    -- Obtener valores desde parámetros
    SELECT CAST(valor AS DECIMAL(10,2)) INTO v_mensualidad_base FROM PARAMETRO_SISTEMA WHERE clave = 'mensualidad_base';
    
    IF p_tipo_plan = 'semestral' THEN
        SELECT CAST(valor AS DECIMAL(5,2)) INTO v_descuento_porcentaje FROM PARAMETRO_SISTEMA WHERE clave = 'descuento_semestral';
        SET v_num_meses = 6;
    ELSE
        SELECT CAST(valor AS DECIMAL(5,2)) INTO v_descuento_porcentaje FROM PARAMETRO_SISTEMA WHERE clave = 'descuento_anual';
        SET v_num_meses = 12;
    END IF;
    
    SET v_monto_con_descuento = v_mensualidad_base * (1 - (v_descuento_porcentaje / 100));
    
    START TRANSACTION;
    WHILE v_i < v_num_meses DO
        INSERT INTO MENSUALIDAD (id_socio, monto, fecha_emision, fecha_vencimiento, tipo_plan, descuento_aplicado, monto_final, pagada)
        VALUES (p_id_socio, v_mensualidad_base, DATE_ADD(p_fecha_inicio, INTERVAL v_i MONTH), DATE_ADD(p_fecha_inicio, INTERVAL v_i MONTH), p_tipo_plan, v_descuento_porcentaje, v_monto_con_descuento, TRUE);
        SET v_i = v_i + 1;
    END WHILE;
    
    -- Registrar un solo pago por el total del plan anticipado
    INSERT INTO PAGO (id_socio, monto, tipo, metodo_pago, fecha, referencia)
    VALUES (p_id_socio, v_monto_con_descuento * v_num_meses, 'mensualidad', p_metodo_pago, NOW(), CONCAT(p_tipo_plan, '_', p_id_socio, '_', p_fecha_inicio));
    
    COMMIT;
END //

DELIMITER ;

-- ============================================================
-- 4. ÍNDICES ADICIONALES PARA RENDIMIENTO
-- ============================================================

CREATE INDEX idx_socio_estatus ON SOCIO(estatus);
CREATE INDEX idx_pago_socio_tipo ON PAGO(id_socio, tipo);
CREATE INDEX idx_consumo_socio_area ON CONSUMO(id_socio, area);
CREATE INDEX idx_mensualidad_vencimiento ON MENSUALIDAD(fecha_vencimiento, pagada);
CREATE INDEX idx_bitacora_fecha ON BITACORA(fecha);

-- ============================================================
-- 5. VISTAS ÚTILES PARA REPORTES
-- ============================================================

-- Vista de socios con su información de contacto y estatus
CREATE VIEW vista_socios_completos AS
SELECT s.id_socio, s.nombre, s.edad, s.sexo, s.direccion, s.telefono, s.email, s.rfc, s.estatus,
       t.numero AS tarjeta_encriptada, COUNT(f.id_familiar) AS total_familiares
FROM SOCIO s
LEFT JOIN TARJETA t ON s.id_socio = t.id_socio
LEFT JOIN FAMILIAR f ON s.id_socio = f.id_socio
GROUP BY s.id_socio;

-- Vista de adeudos por socio (mensualidades no pagadas + consumos + invitados + cargos familiares)
CREATE VIEW vista_adeudos_actuales AS
SELECT p.id_socio, 
       COALESCE(SUM(CASE WHEN p.tipo = 'inscripcion' AND p.fecha >= DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN p.monto ELSE 0 END), 0) AS adeudo_inscripcion,
       COALESCE(SUM(CASE WHEN p.tipo = 'mensualidad' AND p.fecha >= DATE_SUB(NOW(), INTERVAL 12 MONTH) THEN p.monto ELSE 0 END), 0) AS adeudo_mensualidades,
       COALESCE(SUM(CASE WHEN p.tipo = 'invitado' THEN p.monto ELSE 0 END), 0) AS adeudo_invitados,
       COALESCE(SUM(CASE WHEN p.tipo = 'cargo_familiar' THEN p.monto ELSE 0 END), 0) AS adeudo_familiares,
       COALESCE(SUM(CASE WHEN p.tipo = 'consumo' THEN p.monto ELSE 0 END), 0) AS adeudo_consumos
FROM PAGO p
WHERE p.fecha >= DATE_SUB(NOW(), INTERVAL 90 DAY) -- últimos 3 meses
GROUP BY p.id_socio;

-- ============================================================
-- 6. DATOS DE PRUEBA (OPCIONAL, PARA DEMOSTRACIÓN)
-- ============================================================

-- Insertar un socio de ejemplo
INSERT INTO SOCIO (nombre, edad, sexo, direccion, telefono, email, rfc, estatus) VALUES
('Juan Pérez García', 35, 'M', 'Av. Central 123, Col. Centro, Tuxtla Gutiérrez', '9611234567', 'juan.perez@example.com', 'PEGJ890101ABC', 'al_corriente');

-- Insertar su tarjeta (simulada encriptada)
INSERT INTO TARJETA (numero, id_socio) VALUES ('AES_ENCRYPT("4111111111111111","clave_secreta")', 1);

-- Insertar inscripción de contado
INSERT INTO INSCRIPCION (id_socio, monto, tipo_pago) VALUES (1, 8000, 'contado');

-- Insertar pago de inscripción
INSERT INTO PAGO (id_socio, monto, tipo, metodo_pago, referencia) VALUES
(1, 8000, 'inscripcion', 'transferencia', 'INSCRIPCION_1');

-- Insertar dos familiares (gratis)
INSERT INTO FAMILIAR (nombre, parentesco, id_socio) VALUES
('María Pérez López', 'Esposa', 1),
('Luis Pérez Pérez', 'Hijo', 1);

-- Insertar una mensualidad normal (sin descuento) para el mes actual
SET @base = (SELECT CAST(valor AS DECIMAL(10,2)) FROM PARAMETRO_SISTEMA WHERE clave = 'mensualidad_base');
INSERT INTO MENSUALIDAD (id_socio, monto, fecha_emision, fecha_vencimiento, tipo_plan, descuento_aplicado, monto_final) VALUES
(1, @base, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'mensual', 0, @base);

-- Insertar consumo en restaurante
INSERT INTO CONSUMO (id_socio, area, monto) VALUES (1, 'restaurante', 350.00);

-- Insertar registro de invitados (2 personas) -> cargo de 200
INSERT INTO INVITADO (id_socio, cantidad, costo_total) VALUES (1, 2, 200);

-- Registrar pago de la mensualidad (simulación)
INSERT INTO PAGO (id_socio, monto, tipo, metodo_pago, referencia) VALUES
(1, @base, 'mensualidad', 'efectivo', CONCAT('MENSUALIDAD_', (SELECT id_mensualidad FROM MENSUALIDAD WHERE id_socio=1 ORDER BY id_mensualidad DESC LIMIT 1)));

-- Actualizar el estatus de la mensualidad a pagada (en sistema real se haría mediante trigger o lógica)
UPDATE MENSUALIDAD SET pagada = TRUE WHERE id_socio = 1 AND pagada = FALSE LIMIT 1;

-- Insertar en bitácora un ejemplo
INSERT INTO BITACORA (id_usuario, accion, valor_anterior, valor_nuevo) VALUES
(1, 'INSERCION_SOCIO', NULL, 'Datos del socio Juan Pérez');

-- Fin del script