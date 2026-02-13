#!/bin/bash

# =============================
# SMTP Simple User Enum v2.0 
# =============================

# globales
IP=""
PORT=""
WORDLIST=""

# helppanel
usage() {
    echo "Uso: $0 -ip <IP> -p <PORT> -w <WORDLIST>"
    echo "Ejemplo: $0 -ip 10.129.4.178 -p 25 -w users.txt"
    exit 1
}

# Parseo de argumentos
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -ip) IP="$2"; shift 2 ;;
        -p) PORT="$2"; shift 2 ;;
        -w) WORDLIST="$2"; shift 2 ;;
        *) echo "Opción desconocida: $1"; usage ;;
    esac
done

if [[ -z "$IP" || -z "$PORT" || -z "$WORDLIST" ]]; then
    echo "Error: Faltan argumentos."
    usage
fi

# connect
connect_to_smtp() {
    
    exec 3>&- 2>/dev/null
    
    echo "[*] Estableciendo conexión con $IP:$PORT..."
    
    # descriptor 3
    if ! exec 3<>/dev/tcp/$IP/$PORT; then
        echo "[!] Error fatal: No se puede conectar al servidor."
        exit 1
    fi
    
    # Leer banner inicial (220)
    read -u 3 BANNER
    # Enviar HELO para iniciar
    echo "HELO script" >&3
    read -u 3 HELO_RESP
}

# 1
echo "[!] Iniciado!"
connect_to_smtp

# 2
while IFS= read -r user; do
    
    sleep 2

    if ! echo "VRFY $user" >&3 2>/dev/null; then
        echo "[!] Conexión perdida (Broken Pipe). Reconectando..."
        connect_to_smtp
        
        echo "VRFY $user" >&3
    fi
    
    
    read -t 3 -u 3 RESPONSE
    
    # 3
    if [[ -z "$RESPONSE" ]]; then
         echo "[!] Respuesta vacía. Reintentando conexión..."
         connect_to_smtp
         echo "VRFY $user" >&3
         read -u 3 RESPONSE
    fi
    
    CLEAN_RESP=$(echo "$RESPONSE" | tr -d '\r')
    echo "User: $user -> Respuesta: $CLEAN_RESP"   
    
    if [[ "$CLEAN_RESP" == *"421"* ]]; then
        echo "[*] El servidor está saturado de errores (421). Reiniciando sesión..."
        connect_to_smtp
    fi

done < "$WORDLIST"

# Cerrar
echo "QUIT" >&3
exec 3>&-
echo "------------------------------------------------"
echo "[*] Fin del escaneo."
