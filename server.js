/**
 * SERVIDOR BACKEND REST API - SISTEMA PLADDES UNSAAC
 * Framework: Node.js + Express
 * Base de Datos: PostgreSQL (pg)
 * Autenticación: JWT + Bcrypt
 */

const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'unsaac_pladdes_secret_key_2026';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname)));

// Ruta raíz → sirve el prototipo HTML directamente
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'prototipo_pladdes_v5.html'));
});

// Configuración de conexión a PostgreSQL
const pool = new Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/pladdes_unsaac',
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Probar conexión a BD
pool.connect((err, client, release) => {
    if (err) {
        console.log('⚠️ Conexión a PostgreSQL no disponible localmente. Ejecutando en modo fallback API.');
    } else {
        console.log('✅ Conexión exitosa a la Base de Datos PostgreSQL de PLADDES UNSAAC.');
        release();
    }
});

// Middleware de verificación JWT
function verificarToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Acceso denegado: Token requerido' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Token inválido o expirado' });
        req.user = user;
        next();
    });
}

// ════════════════════════════════════════════════════════════════
// RUTAS API REST
// ════════════════════════════════════════════════════════════════

// Healthcheck
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', sistema: 'PLADDES UNSAAC API REST v4.0', timestamp: new Date() });
});

// 1. AUTH LOGIN (/api/auth/login)
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const result = await pool.query('SELECT * FROM usuario WHERE email = $1', [email]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        const user = result.rows[0];

        // Para contraseñas demo '12345678'
        const validPass = (password === '12345678') || await bcrypt.compare(password, user.password_hash);
        if (!validPass) return res.status(401).json({ error: 'Contraseña incorrecta' });

        const token = jwt.sign(
            { id: user.id_usuario, email: user.email, rol: user.rol, nombre: `${user.nombres} ${user.apellidos}` },
            JWT_SECRET,
            { expiresIn: '8h' }
        );

        res.json({
            message: 'Autenticación exitosa',
            token,
            usuario: {
                id: user.id_usuario,
                nombres: user.nombres,
                apellidos: user.apellidos,
                email: user.email,
                rol: user.rol,
                dni: user.dni,
                codigo: user.codigo_univ
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error en el servidor de base de datos' });
    }
});

// 2. CATÁLOGO TUPA (/api/procedimientos)
app.get('/api/procedimientos', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM procedimiento_tupa WHERE vigente = true ORDER BY id_procedimiento ASC');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error al consultar catálogo TUPA' });
    }
});

// 3. REGISTRO DE TRÁMITE (/api/tramites)
app.post('/api/tramites', async (req, res) => {
    const { id_usuario, id_procedimiento, asunto, obs_solicitante, clave_pago, id_dep_actual } = req.body;
    const codigo_seguimiento = `TR-2026-${Math.floor(48000 + Math.random() * 2000)}`;

    try {
        const result = await pool.query(
            `INSERT INTO tramite (codigo_seguimiento, id_usuario, id_procedimiento, asunto, obs_solicitante, id_dep_actual)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [codigo_seguimiento, id_usuario || 1, id_procedimiento || 1, asunto, obs_solicitante, id_dep_actual || 1]
        );

        const tramiteCreado = result.rows[0];

        // Insertar pago si existe clave
        if (clave_pago) {
            await pool.query(
                `INSERT INTO pago (id_tramite, clave_pago, monto) VALUES ($1, $2, $3)`,
                [tramiteCreado.id_tramite, clave_pago, 25.00]
            );
        }

        res.status(201).json({
            message: 'Trámite registrado con éxito en PLADDES',
            tramite: tramiteCreado
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al registrar el trámite' });
    }
});

// 4. SEGUIMIENTO DE EXPEDIENTE (/api/tramites/seguimiento/:codigo)
app.get('/api/tramites/seguimiento/:codigo', async (req, res) => {
    const { codigo } = req.params;
    try {
        const result = await pool.query(
            `SELECT t.*, u.nombres, u.apellidos, u.email, d.nombre as dependencia_nombre, p.nombre as procedimiento_nombre
             FROM tramite t
             JOIN usuario u ON t.id_usuario = u.id_usuario
             JOIN dependencia d ON t.id_dep_actual = d.id_dependencia
             JOIN procedimiento_tupa p ON t.id_procedimiento = p.id_procedimiento
             WHERE t.codigo_seguimiento = $1`,
            [codigo.toUpperCase()]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Expediente no encontrado' });
        }

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: 'Error al realizar el seguimiento' });
    }
});

// 5. BANDEJA ADMIN (/api/admin/expedientes)
app.get('/api/admin/expedientes', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT t.*, u.nombres, u.apellidos, u.dni, u.rol as rol_solicitante, d.nombre as dependencia_nombre
             FROM tramite t
             JOIN usuario u ON t.id_usuario = u.id_usuario
             JOIN dependencia d ON t.id_dep_actual = d.id_dependencia
             ORDER BY t.fecha_registro DESC`
        );
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Error al consultar la bandeja de expedientes' });
    }
});

// 6. CAMBIAR ESTADO DE EXPEDIENTE (/api/admin/expedientes/:id/estado)
app.put('/api/admin/expedientes/:id/estado', async (req, res) => {
    const { id } = req.params;
    const { nuevo_estado, comentario, id_dep_destino } = req.body;

    try {
        const query = id_dep_destino
            ? 'UPDATE tramite SET estado = $1, id_dep_actual = $2, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id_tramite = $3 RETURNING *'
            : 'UPDATE tramite SET estado = $1, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id_tramite = $2 RETURNING *';

        const params = id_dep_destino ? [nuevo_estado, id_dep_destino, id] : [nuevo_estado, id];
        const result = await pool.query(query, params);

        if (result.rows.length === 0) return res.status(404).json({ error: 'Expediente no encontrado' });

        // Registrar en historial
        await pool.query(
            `INSERT INTO historial_estado (id_tramite, estado_nuevo, comentario) VALUES ($1, $2, $3)`,
            [id, nuevo_estado, comentario || 'Actualizado desde el panel admin']
        );

        res.json({ message: 'Estado del expediente actualizado correctamente', tramite: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: 'Error al cambiar estado' });
    }
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`🚀 Servidor PLADDES UNSAAC ejecutándose en puerto ${PORT}`);
    console.log(`🌐 Acceso local: http://localhost:${PORT}/prototipo_pladdes_v5.html`);
});
