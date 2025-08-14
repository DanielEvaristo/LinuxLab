#!/usr/bin/env bash
# Script para generar archivos con comandos y su descripción en español

# Carpeta donde guardaremos los resultados
CARPETA="comandos_con_ayuda"
mkdir -p "$CARPETA"  # crea la carpeta si no existe

# Recorremos cada letra del abecedario
for LETRA in {a..z}; do
    ARCHIVO="$CARPETA/comandos_${LETRA}.txt"
    > "$ARCHIVO"  # vacía el archivo si existe

    # Buscamos todos los comandos que empiezan con la letra
    for CMD in $(compgen -c "$LETRA" | sort -u); do
        # Intentamos obtener la descripción en español
        DESCRIPCION=$(LANG=es_ES.UTF-8 whatis "$CMD" 2>/dev/null | head -n 1)

        if [ -n "$DESCRIPCION" ]; then
            echo "$DESCRIPCION" >> "$ARCHIVO"
        else
            echo "$CMD - (sin entrada en el manual)" >> "$ARCHIVO"
        fi
    done

    echo "Generado: $ARCHIVO"
done
