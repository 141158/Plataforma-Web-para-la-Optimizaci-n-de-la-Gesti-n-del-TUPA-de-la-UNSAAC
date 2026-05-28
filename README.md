# PLADDES: Plataforma de Trámites Digitales - TUPA (UNSAAC)

**PLADDES** es un sistema web concebido para digitalizar, optimizar y automatizar los trámites de la **Universidad Nacional de San Antonio Abad del Cusco (UNSAAC)**, en cumplimiento con el **Texto Único de Procedimientos Administrativos (TUPA)**. La plataforma está orientada a agilizar la gestión administrativa para estudiantes, egresados, docentes, personal administrativo y público en general, eliminando la burocracia presencial y brindando trazabilidad en tiempo real.

---

## 📋 Entregable 1: Plan de Proyecto e Interfaces (Hito Unidad I)

Este repositorio contiene los artefactos de ingeniería y diseño correspondientes a la primera fase del proyecto (Entregable 1 - Hito de Unidad I), completado satisfactoriamente para su revisión.

### Contenido del Entregable:
1. **Formulación de Especificaciones de Requerimientos**:
   - Documento completo de especificaciones del proyecto y especificación técnica en [PROYECTO_DESARROLLO_DE_SOFTWARE_.pdf](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/PROYECTO_DESARROLLO_DE_SOFTWARE_.pdf).
2. **Diseño de Base de Datos Relacional**:
   - Carpeta contenedora: [DISEÑO DE LA BASE DE DATOS](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/DISEÑO%20DE%20LA%20BASE%20DE%20DATOS)
   - Diagrama Entidad-Relación (DER): [entidad relacion.png](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/DISEÑO%20DE%20LA%20BASE%20DE%20DATOS/entidad%20relacion.png)
   - Matriz de Trazabilidad y Casos de Uso: [Matriz.png](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/DISEÑO%20DE%20LA%20BASE%20DE%20DATOS/Matriz.png) y [Casos de uso.png](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/DISEÑO%20DE%20LA%20BASE%20DE%20DATOS/Casos%20de%20uso.png)
3. **Prototipado Dinámico Interactivo**:
   - Prototipo HTML autocontenido de alta fidelidad: [prototipo_pladdes_v5.html](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/prototipo_pladdes_v5.html).
   - Capturas de pantallas detalladas del diseño del sistema: [IMAGENES DEL PROTOTIPO/](file:///c:/Users/adrs0/OneDrive/Escritorio/Proyecto%20Desarrollo%20-%20TUPA/IMAGENES%20DEL%20PROTOTIPO)

---

## 🎨 Prototipo Interactivo de Interfaz de Usuario

El archivo `prototipo_pladdes_v5.html` es una simulación dinámica completa de la plataforma en su versión final. Para visualizarlo y probarlo:
1. Abra el archivo directamente en cualquier navegador web moderno (Chrome, Edge, Firefox).
2. Podrá interactuar con las siguientes vistas implementadas:
   - **Inicio / Landing Page**: Conexión e indicaciones para Público, Estudiante y Docente.
   - **Buscador y Catálogo TUPA**: Filtrado inteligente de trámites.
   - **Wizard de Trámite en 4 Pasos**:
     - *Paso 1*: Ingreso de datos del interesado y validaciones de correo/celular.
     - *Paso 2*: Selección dinámica de peticiones según el TUPA.
     - *Paso 3*: Carga digital de requisitos obligatorios y validación de Clave de Pago.
     - *Paso 4*: Resumen de confirmación con declaración jurada para el envío.
   - **Bandeja de Entrada Administrativa (Panel Admin)**: Simulación de derivación y aprobación de expedientes para personal de dependencias universitarias.
   - **Seguimiento con Línea de Tiempo**: Consulta del estado de trámites en tiempo real.

---

## 🗺️ Hoja de Ruta del Proyecto (Plan de Sprints)

A continuación se detalla el cronograma propuesto para el desarrollo e implementación del sistema PLADDES:

```mermaid
gantt
    title Cronograma General del Proyecto - PLADDES UNSAAC
    dateFormat  YYYY-MM-DD
    section Entregables
    Entregable 1 (Hito Unidad I)           :active, e1, 2026-05-01, 2026-05-28
    section Sprints
    Sprint 1: Arquitectura y Catálogo      : s1, 2026-05-29, 2026-06-16
    Sprint 2: Core de Trámites y Archivos  : s2, 2026-06-17, 2026-07-03
    Sprint 3: Trazabilidad y Pagos        : s3, 2026-07-04, 2026-07-21
    Sprint 4: Panel, Reportes y Cierre     : s4, 2026-07-22, 2026-08-05
```

### 🎯 Desglose de Sprints

#### **Entregable 1: Plan de Proyecto e Interfaces (Hasta el 28 de mayo)**
- Formulación de especificaciones de ingeniería de requerimientos.
- Plan de proyecto (ámbitos, objetivos, metodología y presupuesto).
- Diseño de base de datos relacional y prototipado dinámico en Figma.
- Configuración de repositorios en GitHub.

#### **Sprint 1: Arquitectura, Autenticación y Catálogo TUPA (29 de mayo - 16 de junio | 3 semanas)**
- Inicialización de base de datos en PostgreSQL y GitFlow en GitHub.
- Backend base en Node.js + Express y seguridad JWT + bcrypt.
- Interfaz pública (Landing Page) en React.js y Tailwind CSS.
- Catálogo digital interactivo con los 80+ procedimientos del TUPA.

#### **Sprint 2: Core de Trámites y Carga Documental (17 de junio - 03 de julio | 2.5 semanas)**
- Wizard dinámico por pasos en React para el registro ágil de solicitudes.
- Validaciones en tiempo real y mensajes de error contextuales de cara al usuario.
- Módulo de backend para asociación dinámica de requisitos documentales específicos.
- Sistema de carga, control de peso y almacenamiento de archivos sustentorios.

#### **Sprint 3: Trazabilidad, Notificaciones y Pagos (04 de julio - 21 de julio | 2.5 semanas)**
- Módulo de consulta ciudadana con línea de tiempo interactiva de estados de expedientes.
- Cálculo automático de fecha proyectada de resolución según plazos oficiales del TUPA.
- Alertas automáticas por correo electrónico (Nodemailer + SMTP) ante cambios de estado.
- Módulo para registro y pre-verificación de códigos de pago/vouchers de Caja UNSAAC.

#### **Sprint 4: Panel Administrativo, Reportes y Cierre (22 de julio - 05 de agosto | 2 semanas)**
- Bandeja de expedientes digital para dependencias con opciones de derivación inter-áreas.
- Dashboard de analítica estadística gerencial con exportación a formatos PDF y Excel.
- Implementación de pruebas de software unitarias y de integración (cobertura ≥ 70%).
- Despliegue funcional en la nube (Railway/Render) y entrega de la documentación técnica final.

---

## 🛠️ Tecnologías y Arquitectura Propuesta
- **Frontend**: React.js, Tailwind CSS, Bootstrap 5 (prototipo).
- **Backend**: Node.js, Express.js.
- **Base de Datos**: PostgreSQL (Relacional).
- **Control de Versiones**: Git & GitHub con flujo de trabajo GitFlow.
- **Servicio de Correos**: Nodemailer (SMTP).
- **Despliegue**: Railway / Render.
