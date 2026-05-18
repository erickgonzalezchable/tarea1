# Sistema de Gestión de Socios - Club Deportivo

## 📋 Descripción
Aplicación completa de gestión de socios para un club deportivo, desarrollada con Python y MariaDB/MySQL.

**Características:**
- ✅ Gestión de socios (registro, consultas, historial)
- ✅ Administración de familiares (máximo 6 por socio)
- ✅ Procesamiento de inscripciones (contado o a 3 meses)
- ✅ Cobro de mensualidades con descuentos (semestral/anual)
- ✅ Control de acceso y registro de invitados
- ✅ Generación de reportes y PDFs
- ✅ Bitácora de auditoría completa
- ✅ 4 módulos por rol: Secretaría, Contabilidad, Vigilancia, Administración

---

## 🛠️ Requisitos Previos

1. **Python 3.8+** - [Descargar](https://www.python.org/downloads/)
2. **MariaDB 12.2+** - [Descargar](https://mariadb.org/download/)
3. **Git** - [Descargar](https://git-scm.com/)

---

## 📦 Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/erickgonzalezchable/tarea1.git
cd tarea1
```

### 2. Instalar dependencias Python
```bash
pip install -r requirements.txt
```

### 3. Instalar y configurar MariaDB

**Opción A: Instalación en Windows (recomendado)**
```bash
winget install --id MariaDB.Server -e --source winget
```

**Opción B: Descarga manual**
- Descarga desde: https://mariadb.org/download/
- Ejecuta el instalador y sigue los pasos
- Anota el usuario (default: `root`) y contraseña

### 4. Crear la base de datos

Abre MySQL/MariaDB Command Line Client y ejecuta:
```bash
source c:\ruta\hacia\a.sql
```

O usa esta alternativa:
```bash
mysql -u root -p < a.sql
```

### 5. Configurar credenciales

Edita el archivo `config.py`:
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',           # Tu usuario de MariaDB
    'password': 'tu_password', # Tu contraseña
    'database': 'club_socios',
    'raise_on_warnings': True
}
```

---

## ▶️ Ejecución

```bash
python interfas.py
```

**Credenciales de prueba:**
- Usuario: `admin`
- Contraseña: Debes cambiarla en el primer login
- La app te solicitará una nueva contraseña al ingresar

---

## 📂 Estructura del Proyecto

```
tarea1/
├── a.sql              # Script de base de datos MariaDB
├── interfas.py        # Aplicación principal (GUI)
├── config.py          # Configuración de credenciales
├── requirements.txt   # Dependencias Python
├── README.md          # Este archivo
└── estado_cuenta_*.pdf # Reportes generados
```

---

## 🔐 Seguridad

- ✅ Contraseñas hasheadas con bcrypt
- ✅ Números de tarjeta encriptados con Fernet
- ✅ Bitácora de auditoría para todas las acciones
- ✅ Validación de horarios operativos (Mar-Dom, 7:45-20:15)
- ✅ Roles y permisos por usuario

---

## 👥 Roles y Permisos

| Rol | Funciones |
|-----|----------|
| **Secretaría** | Registrar socios, agregar familiares, procesar inscripciones, consultar datos |
| **Contabilidad** | Cobrar mensualidades, generar estados de cuenta, liquidar adeudos |
| **Vigilancia** | Validar acceso de socios, registrar invitados |
| **Administración** | Gestionar parámetros, ver bitácora, crear usuarios |

---

## 📝 Notas Importantes

- La aplicación valida que solo opera **Martes a Domingo** de **7:45 a 20:15**
- Los primeros 3 familiares de un socio son gratis; del 4to al 6to hay cargo de $500
- Las mensualidades tienen descuentos: 10% semestral, 20% anual
- Todos los cambios se registran en la bitácora para auditoría

---

## 🆘 Solución de Problemas

### Error: "ModuleNotFoundError: No module named 'mysql'"
```bash
pip install --upgrade mysql-connector-python
```

### Error: "Can't connect to MySQL server"
- Verifica que MariaDB está en ejecución
- Windows: Services > MariaDB está corriendo
- Verifica usuario y contraseña en `config.py`

### No abre la interfaz gráfica
- Asegúrate de tener conexión a la base de datos
- Revisa que la BD está creada: `mysql -u root -p -e "USE club_socios; SHOW TABLES;"`

---

## 📧 Contacto

Desarrollado por: Erick González  
Repositorio: https://github.com/erickgonzalezchable/tarea1

---

**Versión:** 1.0 - Mayo 2026
