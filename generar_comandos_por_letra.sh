#!/usr/bin/env bash
# Generar archivos con comandos que comienzan con cada letra (a..z)
# Usar compgen -c <prefijo> y guardar en comandos_que_comienzan_con_<letra>.txt


# Carpeta donde se guardarán todos los archivos
CARPETA_SALIDA="comandos_por_letra"

# Crear la carpeta
mkdir -p "$CARPETA_SALIDA"

# Recorrer de la a a la z
for L in {a..z}; do
    archivo_salida="${CARPETA_SALIDA}/comandos_con_${L}.txt"

    # Listar todos los comandos que empiezan con la letra $L
    # Incluye ejecutables en PATH, funciones, alias, y comandos internos
    compgen -c "$L" | sort -u > "$archivo_salida"

    # Mostrar un resumen: número de líneas y nombre del archivo
    printf "%d %s\n" "$(wc -l < "$archivo_salida")" "$archivo_salida"
done
