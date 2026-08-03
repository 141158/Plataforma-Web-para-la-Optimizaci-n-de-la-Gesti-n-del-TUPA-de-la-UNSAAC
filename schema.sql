-- =============================================================================
-- ESQUEMA DE BASE DE DATOS POSTGRESQL - SISTEMA PLADDES TUPA (UNSAAC 2024 / 2021)
-- Basado en la Res. CU-520-2024-UNSAAC y el Diagrama ER del Plan de Proyecto
-- =============================================================================

DROP TABLE IF EXISTS notificacion CASCADE;
DROP TABLE IF EXISTS historial_estado CASCADE;
DROP TABLE IF EXISTS pago CASCADE;
DROP TABLE IF EXISTS documento_adjunto CASCADE;
DROP TABLE IF EXISTS tramite CASCADE;
DROP TABLE IF EXISTS requisito CASCADE;
DROP TABLE IF EXISTS procedimiento_tupa CASCADE;
DROP TABLE IF EXISTS sesion CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;
DROP TABLE IF EXISTS dependencia CASCADE;

DO $$ BEGIN
    CREATE TYPE rol_enum AS ENUM ('estudiante', 'docente', 'administrativo', 'dependencia', 'superadmin', 'publico');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE estado_tramite_enum AS ENUM ('Pendiente', 'En Revisión', 'Observado', 'Completado', 'Archivado');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE dependencia (
    id_dependencia SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(50) DEFAULT 'OFICINA',
    id_padre INT REFERENCES dependencia(id_dependencia) ON DELETE SET NULL
);

CREATE TABLE usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni CHAR(8) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    codigo_univ VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    rol rol_enum NOT NULL DEFAULT 'estudiante',
    sede VARCHAR(50) DEFAULT 'Cusco - Sede Principal',
    activo BOOLEAN DEFAULT TRUE,
    id_dependencia INT REFERENCES dependencia(id_dependencia) ON DELETE SET NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sesion (
    id_sesion SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    token_hash CHAR(255) UNIQUE NOT NULL,
    ip_origen INET,
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL,
    activa BOOLEAN DEFAULT TRUE
);

CREATE TABLE procedimiento_tupa (
    id_procedimiento SERIAL PRIMARY KEY,
    codigo CHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(250) NOT NULL,
    seccion VARCHAR(50) DEFAULT 'GENERAL',
    rol_solicitante rol_enum NOT NULL,
    costo DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    plazo_dias INT NOT NULL DEFAULT 15,
    silencio_admin VARCHAR(20) DEFAULT 'POSITIVO',
    vigente BOOLEAN DEFAULT TRUE,
    resolucion_ref VARCHAR(100) DEFAULT 'Res. CU-520-2024-UNSAAC',
    id_dep_destino INT REFERENCES dependencia(id_dependencia)
);

CREATE TABLE requisito (
    id_requisito SERIAL PRIMARY KEY,
    id_procedimiento INT NOT NULL REFERENCES procedimiento_tupa(id_procedimiento) ON DELETE CASCADE,
    descripcion VARCHAR(350) NOT NULL,
    tipo VARCHAR(50) DEFAULT 'PDF',
    formato_aceptado VARCHAR(50) DEFAULT 'PDF, ZIP, RAR',
    obligatorio BOOLEAN DEFAULT TRUE,
    orden SMALLINT DEFAULT 1
);

CREATE TABLE tramite (
    id_tramite SERIAL PRIMARY KEY,
    codigo_seguimiento CHAR(20) UNIQUE NOT NULL,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario),
    id_procedimiento INT NOT NULL REFERENCES procedimiento_tupa(id_procedimiento),
    asunto VARCHAR(300) NOT NULL,
    obs_solicitante TEXT,
    estado estado_tramite_enum DEFAULT 'Pendiente',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_limite DATE,
    declaracion_jurada BOOLEAN DEFAULT TRUE,
    id_dep_actual INT REFERENCES dependencia(id_dependencia)
);

CREATE TABLE documento_adjunto (
    id_documento SERIAL PRIMARY KEY,
    id_tramite INT NOT NULL REFERENCES tramite(id_tramite) ON DELETE CASCADE,
    id_requisito INT REFERENCES requisito(id_requisito),
    nombre_archivo VARCHAR(200) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL,
    tipo_mime VARCHAR(50) DEFAULT 'application/pdf',
    tamanio_bytes INT,
    fecha_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validado BOOLEAN DEFAULT FALSE,
    obs_validacion TEXT
);

CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_tramite INT NOT NULL REFERENCES tramite(id_tramite) ON DELETE CASCADE,
    clave_pago CHAR(20) UNIQUE NOT NULL,
    monto DECIMAL(8,2) NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_pago VARCHAR(20) DEFAULT 'VERIFICADO',
    voucher_ruta VARCHAR(500),
    verificado_por INT REFERENCES usuario(id_usuario),
    fecha_verificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historial_estado (
    id_historial SERIAL PRIMARY KEY,
    id_tramite INT NOT NULL REFERENCES tramite(id_tramite) ON DELETE CASCADE,
    id_usuario_admin INT REFERENCES usuario(id_usuario),
    estado_anterior estado_tramite_enum,
    estado_nuevo estado_tramite_enum NOT NULL,
    comentario TEXT,
    id_dep_destino INT REFERENCES dependencia(id_dependencia),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notificacion (
    id_notificacion SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_tramite INT REFERENCES tramite(id_tramite) ON DELETE CASCADE,
    asunto VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    canal VARCHAR(20) DEFAULT 'EMAIL',
    leida BOOLEAN DEFAULT FALSE,
    enviada BOOLEAN DEFAULT TRUE,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SEED DATA OFICIAL TUPA 2024 / 2021
-- =============================================================================

INSERT INTO dependencia (id_dependencia, nombre, descripcion, tipo) VALUES
(1, 'Secretaría General', 'Recepción de solicitudes generales de grados y títulos', 'DIRECCION'),
(2, 'VRAC', 'Vicerrectorado Académico UNSAAC', 'VICERRECTORADO'),
(3, 'DIGA', 'Dirección General de Administración', 'DIRECCION'),
(4, 'UTH', 'Unidad de Talento Humano - Gestión Docente', 'UNIDAD'),
(5, 'FIIS', 'Facultad de Ingeniería Informática y de Sistemas', 'FACULTAD');

INSERT INTO usuario (id_usuario, nombres, apellidos, dni, email, telefono, codigo_univ, password_hash, rol, id_dependencia) VALUES
(1, 'Ana', 'García Quispe', '47382910', 'a.garcia@unsaac.edu.pe', '984123456', '182930', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'estudiante', 5),
(2, 'Jhon Kevin', 'Halanocca Surco', '71527700', 'j.halanocca@unsaac.edu.pe', '984765432', '215277', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'estudiante', 5),
(3, 'Luis Álvaro', 'Monzón Condori', '23456789', 'l.monzon@unsaac.edu.pe', '984111222', '001020', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'docente', 5),
(4, 'Elena', 'Ramírez Solís', '10293847', 'admin.sg@unsaac.edu.pe', '984333444', 'ADM001', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'dependencia', 1),
(5, 'Carlos', 'Mendoza Quispe', '30495821', 'admin.vrac@unsaac.edu.pe', '984555666', 'ADM002', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'dependencia', 2),
(6, 'Superadministrador', 'PLADDES', '00000000', 'superadmin@unsaac.edu.pe', '984000000', 'SUP001', '$2a$10$wE6vY/1L/9tV7i/k/O7CeeE8Y9xZ.b2k9B8Q1wR4nN5.d3M9L6a7e', 'superadmin', 1);

-- Procedimientos TUPA reales del archivo PDF oficial
INSERT INTO procedimiento_tupa (id_procedimiento, codigo, nombre, seccion, rol_solicitante, costo, plazo_dias, id_dep_destino) VALUES
(1, 'PA51003F07', 'Calificación de Expediente para Optar el Grado de Bachiller y Rotulado de Diploma', 'GRADOS', 'estudiante', 415.00, 20, 1),
(2, 'PA51008A2B', 'Calificación de Expediente para Optar al Título Profesional: Sustentación de Tesis', 'GRADOS', 'estudiante', 434.00, 10, 1),
(3, 'SE51004D55', 'Certificado de Estudios Semestral', 'CERTIFICADOS', 'estudiante', 9.00, 2, 5),
(4, 'SE510018CA', 'Carné Universitario', 'DOCUMENTOS', 'estudiante', 12.60, 30, 3),
(5, 'PA51001A31', 'Traslado Interno de Escuela Profesional dentro de la misma Facultad', 'ADMINISTRATIVOS', 'estudiante', 110.00, 5, 5),
(6, 'PA51000A49', 'Admisión de Titulados o Graduados para Segunda Profesión', 'ADMINISTRATIVOS', 'publico', 453.00, 5, 5),
(7, 'PA51004007', 'Traslado Externo de otra Universidad a la UNSAAC', 'ADMINISTRATIVOS', 'publico', 450.00, 5, 2),
(8, 'SE51004AB9', 'Constancia de Servicios Docentes', 'CERTIFICADOS', 'docente', 30.00, 5, 4),
(9, 'PA5100E965', 'Solicitud de Acceso a la Información Pública', 'ADMINISTRATIVOS', 'publico', 0.00, 7, 1);

-- Requisitos vinculados por procedimiento
INSERT INTO requisito (id_procedimiento, descripcion, orden) VALUES
(1, 'Solicitud dirigida al Rector solicitando ser declarado Apto para Grado de Bachiller', 1),
(1, 'Copia simple de Certificado de Idioma Extranjero y de Computación Básica', 2),
(1, 'Ficha de seguimiento académico con la conformidad del número de créditos exigidos', 3),
(1, 'Declaración Jurada de haber realizado homologación o convalidación (si aplica)', 4),
(1, 'Dos fotografías a color tamaño carné (4cm x 3cm, terno oscuro, camisa blanca, fondo blanco)', 5),
(1, 'Voucher de pago por derechos de Bachillerato y Rotulado de Diploma (S/ 415.00)', 6),
(2, 'Solicitud dirigida al Rector solicitando calificación de expediente para Título Profesional', 1),
(2, 'Copia simple del Diploma de Grado Académico de Bachiller', 2),
(2, 'Declaración Jurada de no tener antecedentes penales ni judiciales', 3),
(2, 'Voucher de pago por derechos de Título Profesional (S/ 434.00)', 4);

INSERT INTO tramite (id_tramite, codigo_seguimiento, id_usuario, id_procedimiento, asunto, obs_solicitante, estado, id_dep_actual) VALUES
(1, 'TR-2026-48945', 1, 1, 'Calificación de Expediente para Optar el Grado de Bachiller en Ingeniería Informática', 'Adjunto carpeta completa de egresado', 'En Revisión', 1),
(2, 'TR-2026-45231', 1, 3, 'Certificado de Estudios Semestral 2025-II', 'Solicito para trámite de beca', 'Completado', 5),
(3, 'TR-2026-46120', 2, 4, 'Duplicado de Carné Universitario por pérdida', 'Adjunto denuncia policial', 'Observado', 3);

INSERT INTO pago (id_pago, id_tramite, clave_pago, monto, estado_pago) VALUES
(1, 1, '2026-0094821', 415.00, 'VERIFICADO'),
(2, 2, '2026-0034102', 9.00, 'VERIFICADO'),
(3, 3, '2026-0044129', 12.60, 'VERIFICADO');
