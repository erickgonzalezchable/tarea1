#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Configuración centralizada para el Sistema de Gestión de Socios
Modifica estas variables con tus credenciales de acceso a MariaDB
"""

# ==================== CONFIGURACIÓN DE BASE DE DATOS ====================
# Cambia estos valores según tu instalación de MariaDB

DB_CONFIG = {
    'host': 'localhost',      # Host del servidor MariaDB
    'user': 'root',           # Usuario de MariaDB (default: root)
    'password': '',           # Contraseña de MariaDB (dejar vacío si no tiene)
    'database': 'club_socios',
    'raise_on_warnings': True
}

# ==================== CONFIGURACIÓN DE ENCRIPTACIÓN ====================
# Para producción, guarda esta clave en una variable de entorno
# export FERNET_KEY=tu_clave_aqui

FERNET_KEY = None  # Si es None, se genera una nueva en cada ejecución
# En producción, obtenerla de una variable de entorno:
# FERNET_KEY = os.getenv('FERNET_KEY')

# ==================== CONFIGURACIÓN DE HORARIOS ====================
# Horario operativo del sistema (Martes a Domingo)

HORA_APERTURA = "07:45:00"
HORA_CIERRE = "20:15:00"
DIAS_OPERATIVOS = [2, 3, 4, 5, 6, 7]  # 2=Martes, 7=Domingo (1=Lunes cerrado)

# ==================== CONFIGURACIÓN DE INTERFAZ ====================

VENTANA_ANCHO = 900
VENTANA_ALTO = 600
VENTANA_TITULO = "Sistema de Gestión de Socios - Club Deportivo"

# ==================== INSTRUCCIONES DE USO ====================
"""
Para configurar MariaDB:

1. Instala MariaDB 12.2+
2. Abre MySQL/MariaDB Command Line Client
3. Ejecuta: source a.sql
4. Verifica: mysql -u root -p -e "USE club_socios; SHOW TABLES;"
5. Modifica los valores de arriba con tus credenciales

Credenciales por defecto:
  Usuario: admin
  Contraseña: Temporal (debe cambiar en primer login)

Para cambiar contraseña admin:
  mysql -u root -p club_socios
  UPDATE USUARIO SET password = SHA2('tu_nueva_contraseña', 256) WHERE username='admin';
"""
