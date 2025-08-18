# Guía práctica de **tr** (translate/delete characters)

> `tr` transforma **caracteres**: convierte, elimina o comprime repeticiones. Trabaja **carácter a carácter** (no usa regex).

---

## 1) ¿Qué es `tr` y cómo se usa?
`tr` lee de la **entrada estándar** (stdin) y escribe a **salida estándar** (stdout). No acepta nombres de archivo como argumento.

**Sintaxis básica**
```bash
tr SET1 SET2            # traducir (mapear) caracteres de SET1 → SET2
tr -d SET               # eliminar caracteres de SET
tr -s SET               # comprimir repeticiones (squeeze) de caracteres de SET
tr -c SET ...           # usar el COMPLEMENTO de SET (todo lo que NO está en SET)
```

**Ejecutar con archivo**
```bash
tr 'a-z' 'A-Z' < archivo.txt     # redirección
cat archivo.txt | tr 'a-z' 'A-Z' # con tubería
```

---

## 2) Conjuntos de caracteres (SET)
- **Rangos**: `a-z`, `A-Z`, `0-9`
- **Clases POSIX** (portables):  
  `[:lower:]  [:upper:]  [:alpha:]  [:alnum:]  [:digit:]  [:space:]  [:punct:]  [:print:]`
- **Escape de especiales**: tab = `\t`, retorno de carro = `\r`, newline = `\n` (usa comillas $'...' en bash para que se interpreten).

> Consejo: para mayúsculas/minúsculas usa clases POSIX: `[:lower:]` y `[:upper:]` → funcionan mejor en distintos locales.

---

## 3) Traducir (SET1 → SET2)

### 3.1 Minúsculas ↔ MAYÚSCULAS
```bash
tr '[:lower:]' '[:upper:]' < texto.txt
tr '[:upper:]' '[:lower:]' < texto.txt
```

### 3.2 Reemplazar separadores (coma → barra)
```bash
tr ',' '|' < datos.csv > datos.pipe
```
> **Limite**: `tr` no entiende comillas ni escapes de CSV; si hay comas dentro de comillas, usa `awk` o herramientas CSV/`sed`.

### 3.3 ROT13 (cifrado de demostración)
```bash
tr 'A-Za-z' 'N-ZA-Mn-za-m' < mensaje.txt
```

### 3.4 Mapeo a un solo carácter
Si `SET2` es más corto, el último carácter se **repite**:
```bash
echo 'abc123' | tr 'abc' 'X'    # a,b,c → X
```

---

## 4) Eliminar (`-d`) y comprimir (`-s`)

### 4.1 Eliminar dígitos
```bash
tr -d '0-9' < archivo.txt
```

### 4.2 Eliminar todo salvo texto imprimible (conservar saltos de línea)
```bash
tr -cd '[:print:]\n' < archivo.bin
```

### 4.3 Comprimir espacios/tabs múltiples a **uno**
```bash
# Método robusto en dos pasos (traduce todo espacio en blanco a ' ' y luego comprime)
tr '[:space:]' ' ' < texto.txt | tr -s ' ' > texto_normalizado.txt
```

### 4.4 Reemplazar tabs por espacios (y comprimir)
```bash
# En bash para tab usa $'\t'
tr $'\t' ' ' < texto.txt | tr -s ' '
```

### 4.5 Tokenizar palabras: todo lo que NO sea alfanumérico → salto de línea
```bash
tr -cs '[:alnum:]' '\n' < texto.txt | sort | uniq -c | sort -nr
```

### 4.6 Quitar CR de finales de línea (convertir CRLF→LF)
```bash
tr -d $'\r' < windows.txt > unix.txt
```

---

## 5) Complemeto (`-c`): “lo que NO está en el set”
- Con `-c`, `tr` actúa sobre el **complemento** del conjunto.

**Ejemplos**
```bash
# Conservar solo dígitos y saltos de línea
tr -cd '0-9\n' < entrada.txt

# Colapsar todo lo que NO sea espacio en blanco en un solo espacio
tr -cs '[:space:]' ' ' < texto.txt
```

---

## 6) Buenas prácticas y límites
- `tr` **no** usa expresiones regulares ni entiende multicaracter: trabaja **carácter a carácter**.
- Con **UTF‑8** y acentos puede variar por locale; para reemplazos con tildes usa preferentemente `sed`/`awk`.  
- Para CSV/JSON reales, prefiere herramientas específicas o `awk`.
- No pases archivo como argumento: usa redirección `<` o pipe `|`.
- Si tu shell no interpreta `\t`/`\r`, usa `$'...'` (bash) o `printf` para generar esos caracteres.

---

## 7) Combinaciones útiles
```bash
# Solo líneas que contienen "error" → mayúsculas → contar palabras
grep -i 'error' log.txt | tr '[:lower:]' '[:upper:]' | tr -cs '[:alpha:]' '\n' | wc -l

# Normalizar espacios y quedarte con 2 columnas
cat archivo.txt | tr '[:space:]' ' ' | tr -s ' ' | cut -d' ' -f1,2

# Eliminar todo menos dígitos y puntos (útil para limpiar cantidades)
tr -cd '0-9.\n' < montos.txt
```

---

## 8) Mini‑ejercicios (hazlos y comenta resultados)

1) Convierte a MAYÚSCULAS todo un archivo sin tocar el original.  
```bash
tr '[:lower:]' '[:upper:]' < texto.txt > texto_upper.txt
```

2) Deja un solo espacio entre palabras (tabs/espacios múltiples → 1).  
```bash
tr '[:space:]' ' ' < texto.txt | tr -s ' ' > texto_normal.txt
```

3) De un texto, extrae **solo números de teléfono** (mantén dígitos y `+`, `-`, espacios y `(` `)`).  
```bash
tr -cd '0-9+() -\n' < contactos.txt
```

4) Cuenta palabras (definidas como secuencias alfanuméricas).  
```bash
tr -cs '[:alnum:]' '\n' < texto.txt | wc -l
```

5) Pasa de CSV separado por `;` a `,` y elimina dobles comillas.  
```bash
tr ';' ',' < datos.csv | tr -d '"' > datos_simple.csv
```

---

## 9) Referencia rápida
```bash
# A mayúsculas / minúsculas
tr '[:lower:]' '[:upper:]' < in > out
tr '[:upper:]' '[:lower:]' < in > out

# Eliminar / comprimir
tr -d '0-9' < in > out
tr -s ' ' < in > out

# Complemento
tr -cd '[:print:]\n' < in > out
tr -cs '[:alnum:]' '\n' < in > out

# Tabs → espacios, CRLF → LF
tr $'\t' ' ' < in | tr -s ' ' > out
tr -d $'\r' < in > out
```
