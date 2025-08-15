# Guía práctica de **sed** (Stream EDitor)

> Edita texto “en flujo”: buscar, reemplazar, borrar y seleccionar líneas sin abrir un editor.

---

## 1) ¿Qué es `sed`?
`sed` lee la entrada **línea por línea**, aplica **reglas** (patrones y acciones) y escribe el resultado. Por defecto **no modifica** archivos; solo imprime a salida estándar. Para modificar en sitio usa `-i` 

---

## 2) Sintaxis básica
```bash
sed 'COMANDOS' archivo
echo "texto" | sed 'COMANDOS'
```
- Puedes encadenar varios comandos separándolos con `;` o usando `-e '...' -e '...'`.
- GNU sed permite `-E` para usar **expresiones regulares extendidas** (ERE) sin escapes.

---

## 3) Comandos más usados (chuleta)
| Comando / Opción | Qué hace |
|-----------------:|:---------|
| `s/patrón/reemplazo/flags` | **Sustituye** `patrón` por `reemplazo`. |
| `p` (print) | **Imprime** la línea (útil con `-n`). |
| `d` (delete) | **Borra** la línea (no se imprime). |
| `-n` | Modo “silencioso”: no imprime nada salvo lo que ordenes (`p`). |
| `-i[.bak]` | Edita el archivo **en sitio** (opcionalmente crea copia `.bak`). |
| `-E` | Activa regex extendidas (usa `+ ? | ()` sin escapes). |
| Direcciones | Limitar dónde aplicar (números de línea, patrones, rangos). |

**Flags útiles de `s///`:**
- `g` → global (todas las coincidencias en la línea).  
- `N` (número) → solo la **N‑ésima** coincidencia en la línea (p. ej. `s/x/y/2`).  
- `p` → imprime la línea si hubo reemplazo (útil con `-n`).  
- `I` → ignorar mayúsc/minúsculas (GNU sed).

> Consejo: si tu patrón/reemplazo contienen `/`, cambia el **delimitador**: `s#foo/bar#baz#` o `s|foo|bar|`.

---

## 4) Sustituciones (search & replace)

### 4.1 Reemplazo simple (primera coincidencia por línea)
```bash
sed 's/ERROR/ALERTA/' logs.txt
```

### 4.2 Reemplazo global
```bash
sed 's/ERROR/ALERTA/g' logs.txt
```

### 4.3 Reemplazo solo si coincide (e imprimir solo esas líneas)
```bash
sed -n 's/ERROR/ALERTA/p' logs.txt
# -n silencia todo; 'p' imprime solo líneas donde hubo reemplazo
```

### 4.4 Reemplazo insensible a mayúsculas (GNU sed)
```bash
sed 's/error/ALERTA/gI' logs.txt
```

### 4.5 Usando otro delimitador (evitar escapar /)
```bash
sed 's#/var/log#/logs#g' rutas.txt
```

### 4.6 Reemplazo con **backreferences** y `&`
- `&` → el texto que coincidió con el patrón.  
- ``, ``… → grupos capturados entre paréntesis.
```bash
echo "id=123" | sed -E 's/id=([0-9]+)/ID:& (num )/'
# Salida: ID:id=123 (num 123)
```

---

## 5) Direcciones (dónde aplicar)

### 5.1 Solo líneas que coinciden con un patrón
```bash
sed '/ERROR/s/timeout/TIMEOUT/' logs.txt
# Ejecuta s/// solo en líneas que contienen ERROR
```

### 5.2 Por número de línea
```bash
sed '1s/^/# cabecera\n/' archivo.txt      # solo en la línea 1
sed '1,3s/foo/bar/g' archivo.txt           # del 1 al 3
sed '3,$ s/foo/bar/g' archivo.txt          # de la 3 hasta el final
```

### 5.3 Rangos por patrones
```bash
sed '/BEGIN/,/END/ s/foo/bar/g' archivo.txt
```

### 5.4 Borrar líneas (`d`)
```bash
sed '/^#/d' archivo.conf       # borra comentarios (líneas que empiezan con #)
sed '2,5d' archivo.txt         # borra líneas 2 a 5
```

### 5.5 Imprimir solo lo que coincide (`-n` + `p`)
```bash
sed -n '/WARN/p' logs.txt
```

---

## 6) Edición en sitio (`-i`) con copia de seguridad
```bash
# Linux (GNU sed)
sed -i 's/localhost/127.0.0.1/g' config.txt

# Crear copia antes de editar
sed -i.bak 's/DEBUG/INFO/g' app.conf

# macOS/BSD sed requiere extensión explícita (usa '' para sin copia)
sed -i '' 's/DEBUG/INFO/g' app.conf
```

---

## 7) Regex con `sed` (BRE vs ERE)
- Por defecto, `sed` usa **BRE** (Basic). El `+ ? | ()` deben **escaparse**: `\+ \? \| \(\)`
- Con `-E` usas **ERE** (Extended) y ya no escapas:
```bash
# Con BRE (por defecto)
sed 's/\(foo\)\{2,\}/BAR/' archivo

# Con ERE (más legible)
sed -E 's/(foo){2,}/BAR/' archivo
```

---

## 8) Casos prácticos rápidos
```bash
# 8.1 Compactar espacios en blanco múltiples a uno solo
sed -E 's/[[:space:]]+/ /g' texto.txt

# 8.2 Quitar espacios al inicio y final (trim) de cada línea
sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' texto.txt

# 8.3 Enmascarar emails (dejar solo el dominio)
sed -E 's/[[:alnum:]_.+-]+@([[:alnum:].-]+)/***@\1/g' usuarios.txt

# 8.4 Numerar líneas (prefijo con el número)
nl -ba archivo.txt | sed 's/\t/: /'

# 8.5 Comentar líneas que contienen palabra clave
sed '/TODO/s/^/# /' notas.txt

# 8.6 Insertar texto antes/después de líneas que coinciden
sed '/^Title:/i\
# Documento procesado\
' doc.txt     # antes (insert)
sed '/^Title:/a\
# Fin de sección\
' doc.txt          # después (append)

# 8.7 Reemplazar la N‑ésima coincidencia en la línea (solo la 2ª)
sed 's/:/ → /2' rutas.txt
```

> Nota: Los comandos `i\texto` y `a\texto` usan barras invertidas para nuevas líneas y requieren escapar adecuadamente. En GNU sed también puedes usar `printf` con `-e` en el shell para construir cadenas con `\n`.

---

## 9) Procesar muchos archivos

### 9.1 Con `-i` en una carpeta (GNU sed)
```bash
sed -i 's/DEBUG/INFO/g' *.conf
```

### 9.2 Con `find` (más control)
```bash
find . -type f -name '*.conf' -print0 \
| xargs -0 sed -i.bak 's/DEBUG/INFO/g'
```

---

## 10) Mini‑ejercicios (hazlos y comenta resultados)

1) En `logs.txt`, cambia `ERROR` por `ALERTA` solo en líneas que contengan `timeout`.  
```bash
sed '/timeout/s/ERROR/ALERTA/g' logs.txt
```

2) En `rutas.txt`, sustituye `/var/www/` por `/srv/www/` usando `#` como delimitador.  
```bash
sed 's#/var/www/#/srv/www/#g' rutas.txt
```

3) Deja en cada línea solo **una** separación entre palabras (espacios múltiples → 1).  
```bash
sed -E 's/[[:space:]]+/ /g' texto.txt
```

4) En `usuarios.txt`, enmascara el usuario del email manteniendo el dominio (p. ej., `ana@acme.com` → `***@acme.com`).  
```bash
sed -E 's/[[:alnum:]_.+-]+@([[:alnum:].-]+)/***@\1/g' usuarios.txt
```

5) Borra líneas en blanco o con solo espacios.  
```bash
sed -E '/^[[:space:]]*$/d' archivo.txt
```

---

## 11) Errores comunes
- Olvidar comillas en el patrón y que el shell expanda `* ? [ ]`.  
- Usar `/` como delimitador cuando el patrón tiene muchas `/` (cámbialo por `#` o `|`).  
- Editar “en sitio” sin copia (`-i`) y perder el original por accidente (usa `-i.bak`).  
- En macOS/BSD, olvidar que `-i` requiere **siempre** un argumento (aunque sea `''`).

---

## 12) Referencia rápida
```bash
# Reemplazo básico
sed 's/viejo/nuevo/' archivo

# Global (todas las coincidencias por línea)
sed 's/viejo/nuevo/g' archivo

# Solo imprimir líneas cambiadas
sed -n 's/patrón/reemplazo/p' archivo

# Borrar líneas con patrón
sed '/^#/d' archivo

# Rango por números / por patrones
sed '10,20d' archivo
sed '/BEGIN/,/END/ s/foo/bar/g' archivo

# En sitio (GNU sed / Linux)
sed -i 's/AA/BB/g' archivo

# En sitio con copia (portátil con find + xargs)
find . -name '*.conf' -print0 | xargs -0 sed -i.bak 's/DEBUG/INFO/g'
```
