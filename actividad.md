1. Descripción de la Actividad
El objetivo de esta práctica es proteger una aplicación móvil Flutter contra ataques de intermediario (Man-in-the-Middle - MitM). Los alumnos deberán implementar la técnica de SSL/TLS Pinning (asociación de certificado o clave pública) para asegurar que la app solo se comunique con un servidor de confianza, rechazando conexiones interceptadas por certificados de terceros.
2. Requisitos Técnicos
Framework: Flutter (versión estable).
API de pruebas: Cualquier API pública con HTTPS 
Herramientas de simulación: OWASP ZAP, Charles Proxy o HTTP Toolkit (para simular el ataque MitM).
3. Tareas a Realizar
Extracción: Obtener la huella digital SHA-256 (fingerprint) o el certificado .pem del servidor web elegido.Desarrollo: Crear una app en Flutter que consuma la API usando paquetes como dio o http_certificate_pinning, validando estrictamente el certificado del servidor en cada petición.Prueba de Concepto (PoC): Interceptar el tráfico de la app con un proxy.
Sin Pinning: El proxy debe poder leer las peticiones.
Con Pinning: La app debe detectar el certificado intruso, abortar la conexión de forma segura y mostrar un error controlado en la interfaz.
4. Entregables
Deberán entregar un enlace a un repositorio privado de GitHub que contenga:
Repositorio del proyecto de Flutter limpio y funcional con la lógica de validación implementada.
Reporte PDF  que incluya:
El comando o método utilizado para extraer el SHA-256/certificado del servidor.
Dos capturas de pantalla clave:
Una que demuestre la conexión exitosa en condiciones normales.
Otra que demuestre el bloqueo de la conexión (con el log de error o alerta en la app) al intentar interceptar el tráfico con el proxy.
Una breve conclusión (máximo 1 párrafo) sobre cómo manejarían la expiración o rotación de ese certificado en producción sin romper la app de los usuarios.