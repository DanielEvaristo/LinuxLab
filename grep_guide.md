# Guía práctica de **grep** (GNU grep)

> Aprende a buscar texto de forma efectiva con ejemplos y ejercicios guiados.

---

## 1) ¿Qué es `grep`?
`grep` busca líneas que **coinciden** con un patrón (texto o expresión regular) en archivos o en la entrada estándar. Es una de las herramientas más usadas en Linux para inspeccionar logs, código, configuraciones, etc.

---

## 2) Sintaxis básica
```bash
grep [opciones] 'patrón' archivo(s)
# o con tuberías
comando | grep [opciones] 'patrón'
```
**Consejo:** usa **comillas simples** alrededor del patrón para que el shell no lo interprete (`'ERROR|FATAL'`).

---

## 3) Opciones más usadas (chuleta)
| Opción | Qué hace |
|-------:|:---------|
| `-i` | Ignora mayúsculas/minúsculas (case-insensitive). |
| `-n` | Muestra el número de línea. |
| `-w` | Coincidencia de **palabra completa**. |
| `-c` | Solo cuenta cuántas líneas coinciden. |
| `-v` | Invierte la coincidencia (muestra lo que **no** coincide). |
| `-R` | Busca **recursivo** en subdirectorios (sigue enlaces simbólicos). |
| `-r` | Recursivo sin seguir symlinks. |
| `--include='*.ext'` | Limita la búsqueda a ciertos nombres de archivo. |
| `--exclude='*.ext'` | Excluye archivos. |
| `-l` | Muestra solo los **nombres de archivos** que coinciden. |
| `-L` | Muestra archivos que **no** coinciden. |
| `-E` | Usa **expresiones regulares extendidas** (alternativas con `|`, etc.). |
| `-F` | Trata el patrón como **texto literal** (más rápido que regex). |
| `-A N` / `-B N` / `-C N` | Muestra contexto: **A**fter/**B**efore/**C**ombined (después/antes/alrededor) N líneas. |
| `--color=auto` | Resalta coincidencias (útil en terminal). |

---

## 4) Expresiones regulares esenciales
- **Texto literal**: `'ERROR'`
- **Alternativas** (`-E` o escapar `\|`): `-E 'ERROR|FATAL|WARN'`
- **Anclas**: `'^Inicio'` (empieza la línea), `'fin$'` (termina la línea)
- **Clases**: `'[0-9]+'`, `'[A-Za-z_]+'`, `'[[:digit:]]'`, `'[[:alpha:]]'`
- **Cuantificadores**: `a{3}`, `a{2,5}`, `ab*` (0+), `ab+` (1+), `ab?` (0 o 1)
- **Palabra completa**: `-w 'error'` (similar a `\berror\b`; `\b` requiere `-P`)
- **PCRE (avanzado)**: `-P` activa regex estilo Perl (no siempre disponible en todas las distros).

> Con **`-E`** puedes usar `|`, `+`, `?` sin escapes. Sin `-E`, debes escapar (`\|`, `\+`, `\?`).

---

## 5) Ejemplos prácticos rápidos
Suponiendo un archivo `logs.txt`:
```
2025-08-01 10:00:00 INFO  arranque
2025-08-01 10:01:00 WARN  uso alto de CPU
2025-08-01 10:02:00 ERROR fallo de conexión
2025-08-01 10:03:00 INFO  petición completada
2025-08-01 10:04:00 ERROR timeout
```

### 5.1 Búsqueda simple (insensible a mayúsculas, con números de línea)
```bash
grep -in 'error' logs.txt
```

### 5.2 Contar líneas que coinciden / NO coinciden
```bash
grep -c 'ERROR' logs.txt
grep -vc 'ERROR' logs.txt   # invert match + count
```

### 5.3 Palabra completa y resaltado
```bash
grep -nw --color=auto 'ERROR' logs.txt
```

### 5.4 Múltiples patrones (OR)
```bash
grep -E 'ERROR|WARN' logs.txt
# o varias -e
grep -e 'ERROR' -e 'WARN' logs.txt
```

### 5.5 Contexto alrededor de las coincidencias
```bash
grep -nC 1 'ERROR' logs.txt   # 1 línea antes y después
grep -nA 2 'ERROR' logs.txt   # 2 líneas después
grep -nB 2 'ERROR' logs.txt   # 2 líneas antes
```

### 5.6 Recursivo por directorios, limitado por extensión
```bash
grep -R --include='*.log' -n 'timeout' /var/log
# Excluir archivos o carpetas
grep -R --exclude='*.gz' --exclude-dir='.git' -n 'TODO' .
```

### 5.7 Solo nombres de archivos que contienen el patrón
```bash
grep -Rl 'SECRET_KEY' .
```

### 5.8 Patrón literal (rápido, sin regex)
```bash
grep -F 'a+b?c' archivo.txt   # trata + ? como texto normal
```

---

## 6) Combinaciones útiles
```bash
# Filtrar y poner en mayúsculas lo que coincide
grep -i 'error' logs.txt | tr 'a-z' 'A-Z'

# Reemplazar en la salida (no en el archivo)
grep -n 'ERROR' logs.txt | sed 's/ERROR/ALERTA/g'

# Extraer solo la primera “columna” (antes del primer espacio)
grep -n 'ERROR' logs.txt | awk '{print $1}'

# Contar ocurrencias por tipo
grep -Eo '(INFO|WARN|ERROR)' logs.txt | sort | uniq -c | sort -nr
```

---

## 7) Errores comunes (y cómo evitarlos)
- **Olvidar comillas**: el shell expande `*`, `?`, etc. → usa `'patrón'`.
- **Usar `cat archivo | grep`**: puedes hacer directamente `grep 'patrón' archivo` (aunque el pipe a veces es cómodo).
- **Confundir `-r` y `-R`**: `-R` sigue enlaces simbólicos; `-r` no.
- **Quiero OR y no pongo `-E`**: `grep -E 'uno|dos'` (o `-e` múltiples).

---

## 8) Mini‑ejercicios (hazlos en tu terminal)
> No te doy la respuesta: revisa tu salida y cuéntame qué obtuviste para seguir.

1. Crea `logs.txt` con cinco líneas como el ejemplo y busca `ERROR` ignorando mayúsculas y mostrando números de línea.  
   ```bash
   grep -in 'error' logs.txt
   ```

2. ¿Cuántas líneas **no** tienen `ERROR`?  
   ```bash
   grep -vc 'ERROR' logs.txt
   ```

3. Muestra solo las líneas con `ERROR` **y una línea de contexto antes y después**.  
   ```bash
   grep -nC 1 'ERROR' logs.txt
   ```

4. En una carpeta con varios `.txt`, busca recursivamente “correo” pero **solo** en archivos `.txt`.  
   ```bash
   grep -R --include='*.txt' -n 'correo' .
   ```

5. Cuenta cuántas veces aparecen `INFO`, `WARN` o `ERROR` en `logs.txt`. **Pista**: usa `-Eo`, `sort`, `uniq -c`.  

---

## 9) Consejos de rendimiento
- Si el patrón es literal, usa `-F`.  
- Para muchos archivos, limita con `--include/--exclude` o apóyate en `find`:
  ```bash
  find . -name '*.log' -print0 | xargs -0 grep -n 'timeout'
  ```

---

## 10) Referencia rápida
```bash
# Básico
grep -in 'patrón' archivo

# OR
grep -E 'uno|dos' archivo

# Palabra completa, con color
grep -nw --color=auto 'error' archivo

# Recursivo con filtro de extensión
grep -R --include='*.log' -n 'timeout' .

# Solo nombres de archivos que coinciden / que no coinciden
grep -Rl 'patrón' .
grep -RL 'patrón' .

# Contexto
grep -nC 2 'patrón' archivo

# Contar coincidencias
grep -c 'patrón' archivo
```
