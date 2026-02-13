# SMTP Simple User Enum
Un script en Bash ligero y robusto diseñado para la enumeración de usuarios en servidores SMTP utilizando el comando VRFY.

Esta herramienta fue creada específicamente para resolver problemas de inestabilidad en conexiones SMTP durante pruebas de penetración (CTFs, HackTheBox, etc.), donde los servidores suelen cortar la conexión o bloquear por exceso de errores.

### Características Principales
- Detecta automáticamente desconexiones (Broken pipe, Connection reset) y restablece la sesión TCP sin detener el escaneo.
- Detecta el código de error 421 Too many errors (común en Postfix/Sendmail) y fuerza una reconexión proactiva para reiniciar los contadores del servidor.
- No requiere dependencias externas (como Python, Perl o swaks). Utiliza descriptores de archivo nativos (/dev/tcp) para máxima compatibilidad.
- Incluye un delay configurable entre peticiones para evitar saturar el servidor o ser bloqueado por mecanismos anti-spam básicos :)))

### Requisitos
- Bash (Linux/macOS)

### Uso
1. Dale permisos de ejecución al script:
```bash
chmod +x smtp-users.sh
```
2. Ejecuta la herramienta especificando la IP, el puerto y tu diccionario:
```bash
./smtp-users.sh -ip <IP_OBJETIVO> -p <PUERTO> -w <WORDLIST>
```
Ejemplo
```bash
./smtp-users.sh -ip 10.129.4.178 -p 25 -w /usr/share/wordlists/names.txt
```
### Salida de Ejemplo
```plaintext
[*] Iniciando ataque resiliente (Delay: 2s)...
[*] Estableciendo conexión con 10.129.4.178:25...
User: root -> Respuesta: 250 2.0.0 root
User: admin -> Respuesta: 550 5.1.1 User unknown
User: joshua -> Respuesta: 421 4.7.0 Error: too many errors
[*] El servidor está saturado de errores (421). Reiniciando sesión...
User: joshua -> Respuesta: 250 2.1.0 joshua
```
