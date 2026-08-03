# 🚀 GUÍA DE DESPLIEGUE EN LA NUBE PASO A PASO (NEON.TECH + RENDER.COM)

Esta guía contiene los **pasos exactos, verificados y libres de fallos** para desplegar el **Sistema PLADDES UNSAAC** en internet usando los servicios gratuitos de **Neon.tech** (para la base de datos PostgreSQL) y **Render.com** (para el servidor Node.js y la aplicación web).

---

## 📋 PASO 1: Crear y Poblar la Base de Datos PostgreSQL en Neon.tech (Gratis)

**Neon.tech** es el mejor hosting para PostgreSQL sin costo en la nube (servidor dedicado con soporte SSL).

1. Ingresa a **[https://neon.tech](https://neon.tech)** y crea una cuenta haciendo clic en **"Sign Up"** (puedes ingresar directamente con tu cuenta de GitHub o Google).
2. Haz clic en **"Create a project"** (o "New Project"):
   - **Project name**: `pladdes-unsaac-db`
   - **Database name**: `pladdes_db` (o déjalo por defecto).
   - **Region**: Selecciona **US East (Ohio / N. Virginia)** (es la más rápida para Perú).
   - Haz clic en **"Create Project"**.
3. Aparecerá una pantalla con tu **Connection String** (Cadena de Conexión). Copia esa URL completa, lucirá similar a esto:
   ```text
   postgresql://alex_owner:abc123xyz@ep-cool-sun-123456.us-east-2.aws.neon.tech/pladdes_db?sslmode=require
   ```
4. **Poblar la Base de Datos con el Esquema Oficial**:
   - En el menú lateral izquierdo de Neon, haz clic en **"SQL Editor"**.
   - Abre el archivo `schema.sql` de este proyecto en tu computadora, **copia todo su contenido**, pégalo en el editor de SQL de Neon y haz clic en **"Run"** (o ejecuta Ctrl + Enter).
   - Verás el mensaje `Query executed successfully`. ¡Las 10 tablas relacionales y los datos de prueba ya están en la nube!

---

## 🚀 PASO 2: Subir el Código del Proyecto a GitHub

Render necesita conectarse a tu repositorio de GitHub para compilar el proyecto automáticamente:

1. Ingresa a **[https://github.com](https://github.com)** y crea un repositorio nuevo llamado `pladdes-unsaac`.
2. En la consola/terminal de tu computadora, ejecuta:
   ```bash
   git init
   git add .
   git commit -m "Entrega Producto Final PLADDES UNSAAC"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/pladdes-unsaac.git
   git push -u origin main
   ```

---

## 🌐 PASO 3: Desplegar el Backend y Web en Render.com (Gratis)

**Render.com** alojará tu servidor en Node.js + Express y servirá la interfaz web.

1. Ingresa a **[https://render.com](https://render.com)** e inicia sesión con tu cuenta de **GitHub**.
2. En el panel principal, haz clic en el botón azul **"New +"** y selecciona **"Web Service"**.
3. Selecciona la opción **"Build and deploy from a Git repository"** y conecta tu repositorio `pladdes-unsaac`.
4. Rellena los datos de configuración exacta:
   - **Name**: `pladdes-unsaac` *(este nombre formará tu URL gratuita)*
   - **Region**: `Oregon (US West)` o `Ohio (US East)`
   - **Branch**: `main`
   - **Root Directory**: *(Déjalo en blanco)*
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Instance Type**: `Free`
5. **Configurar Variables de Entorno (Environment Variables)**:
   Baja hasta la sección **"Environment Variables"** y haz clic en **"Add Environment Variable"**:
   - Variable 1:
     - **Key**: `DATABASE_URL`
     - **Value**: *(Pega la URL de conexión que copiaste de Neon.tech en el Paso 1)*
   - Variable 2:
     - **Key**: `JWT_SECRET`
     - **Value**: `unsaac_pladdes_secret_key_2026`
   - Variable 3:
     - **Key**: `NODE_ENV`
     - **Value**: `production`
6. Haz clic en **"Create Web Service"**.

---

## 🎉 PASO 4: Verificación Final del Despliegue

1. Render comenzará el proceso de despliegue y verás los logs en vivo:
   ```text
   ==> Running build command 'npm install'...
   ==> Uploading build...
   ==> Running start command 'npm start'...
   🚀 Servidor PLADDES UNSAAC ejecutándose en puerto 10000
   ✅ Conexión exitosa a la Base de Datos PostgreSQL de PLADDES UNSAAC.
   ```
2. Una vez que diga **"Live"** en verde, copia la URL que Render te asigna en la parte superior izquierda (ejemplo: `https://pladdes-unsaac.onrender.com`).
3. Abre esa URL en cualquier navegador o teléfono móvil:
   - `https://pladdes-unsaac.onrender.com/prototipo_pladdes_v5.html`

---

## 🔑 Credenciales de Prueba Disponibles en el Despliegue

Al ingresar a la URL desplegada, puedes probar el sistema usando el selector **"Usuarios BD Demo"** o ingresar las credenciales:

- 🎓 **Estudiante**: `a.garcia@unsaac.edu.pe` | Pass: `12345678`
- 🎓 **Estudiante**: `j.halanocca@unsaac.edu.pe` | Pass: `12345678`
- 👨‍🏫 **Docente**: `l.monzon@unsaac.edu.pe` | Pass: `12345678`
- 🏢 **Admin Sec. General**: `admin.sg@unsaac.edu.pe` | Pass: `12345678`
- 🏢 **Admin VRAC**: `admin.vrac@unsaac.edu.pe` | Pass: `12345678`
- ⚡ **Superadmin**: `superadmin@unsaac.edu.pe` | Pass: `12345678`
