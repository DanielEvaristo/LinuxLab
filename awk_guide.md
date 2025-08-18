# Guía práctica de **awk** (procesamiento de texto por columnas)

> Aprende a filtrar, transformar y resumir datos en la terminal usando `awk` con ejemplos claros y mini‑ejercicios.

---

## 1) ¿Qué es `awk`?
`awk` es un **lenguaje** orientado a procesar **registros** (líneas) y **campos** (columnas). Te permite:
- Filtrar filas por condiciones.
- Seleccionar columnas (`$1`, `$2`, …).
- Hacer cálculos (sumas, promedios, min/máx).
- Reformatear salida (con `printf`).
- Trabajar con **arreglos asociativos** para agrupar (group‑by).

---

## 2) Sintaxis y flujo
```bash
awk [opciones] 'patrón {acción}' archivo(s)
```
- Lee el archivo **línea por línea** (cada línea = **registro**).
- Divide la línea en **campos** usando un separador (**FS**, por defecto espacios/tabs).
- Evalúa `patrón` y, si es verdadero, ejecuta `{acción}`.

**Ejemplos rápidos:**
```bash
awk '{print $1}' archivo.txt        # primera columna
awk -F',' '{print $1, $3}' datos.csv  # con separador coma
```

---

## 3) Variables y separadores clave
- **`$1`, `$2`, …, `$NF`**: columnas (NF = número de campos de la línea actual).
- **`NR`**: número de registro (línea) global.
- **`FNR`**: número de línea por archivo (se reinicia en cada archivo).
- **`FS`**: separador de campos de entrada (por defecto: espacio/tab).
- **`OFS`**: separador entre campos al **imprimir** (por defecto: espacio).
- **`RS`**: separador de registros de entrada (por defecto: salto de línea).
- **`ORS`**: separador de registros de salida (por defecto: salto de línea).
- **`FILENAME`**: nombre del archivo que se está procesando.

**Cambiar separador:**
```bash
awk -F',' '{print $1,$3}' datos.csv          # entrada
awk -v OFS=';' '{print $1,$2,$3}' archivo    # salida
```

---

## 4) Estructura especial: `BEGIN` / cuerpo / `END`
- **`BEGIN { ... }`**: se ejecuta **antes** de leer la primera línea (útil para configurar `FS`, `OFS`, imprimir cabeceras).
- **`{ ... }`**: acción por cada línea que cumpla el patrón.
- **`END { ... }`**: se ejecuta **al final** (útil para totales, promedios, resúmenes).

**Ejemplo:**
```bash
awk -F',' 'BEGIN{OFS=";"; print "NOMBRE;SUELDO_CON_IVA"} NR>1{ print $1, $3*1.16 }' datos.csv
```

---

## 5) Condiciones, operadores y regex
- Comparaciones: `== != > >= < <=`
- Lógicas: `&& || !`
- Coincidencia regex: `campo ~ /regex/`  (no coincide: `!~`)

**Ejemplos:**
```bash
awk -F',' 'NR>1 && $3 > 1700 {print $1,$3}' datos.csv
awk '/ERROR/{print NR ": " $0}' logs.txt           # patrón solo por regex
awk -F',' '$2 ~ /Chile/ {print $1,$2}' datos.csv
```

---

## 6) `print` vs `printf`
- **`print`** es simple y usa `OFS` y `ORS`.
- **`printf`** da **formato** (como en C): no añade salto de línea por defecto.

```bash
awk -F',' 'NR>1{printf "%-10s %8.2f
", $1, $3}' datos.csv
# %-10s = string alineada a izq. en ancho 10, %8.2f = float ancho 8 con 2 dec.
```

---

## 7) Funciones útiles de `awk`
- **Texto**: `length(str)`, `substr(s,i,n)`, `tolower(s)`, `toupper(s)`, `index(s,t)`
- **Numéricas**: `int(x)`, `sqrt(x)`, `rand()`, `srand()`
- **Regex**: `match(s, r)`, `sub(r, repl, s)`, `gsub(r, repl, s)`
- **Split**: `split(s, arr, sep)` → divide `s` en `arr[1]..arr[n]`

**Ejemplo `gsub` y `toupper`:**
```bash
awk '{ line=$0; gsub(/error/,"ALERTA",line); print toupper(line) }' logs.txt
```

---

## 8) Agregaciones: sumas, promedio, min/máx
```bash
# Suma y promedio de la columna 3 (saltando encabezado)
awk -F',' 'NR>1{s+=$3; n++} END{print "Suma:",s, "Promedio:", s/n}' datos.csv

# Mínimo y máximo
awk -F',' 'NR==2{min=max=$3} NR>2{if($3<min)min=$3; if($3>max)max=$3} END{print "Min:",min, "Max:",max}' datos.csv
```

---

## 9) Group‑by con arreglos asociativos
```bash
# Total por país (columna 2), suma sueldos (columna 3)
awk -F',' 'NR>1{ total[$2]+=$3 } END{ for (p in total) print p, total[p] }' datos.csv

# Conteo por nombre
awk -F',' 'NR>1{ c[$1]++ } END{ for (n in c) printf "%s: %d
", n, c[n] }' datos.csv
```

> Para listar ordenado, ordénalo al final con `sort`:
```bash
awk -F',' 'NR>1{total[$2]+=$3} END{for(p in total) print p,total[p]}' datos.csv | sort -k2,2nr
```

---

## 10) Pasar variables desde la línea de comandos (`-v`)
```bash
# Filtrar por país pasado desde el shell
awk -F',' -v PAIS="Chile" 'NR>1 && $2==PAIS {print $1,$3}' datos.csv
```

---

## 11) Cambiar separadores de entrada/salida
```bash
# FS = coma ; OFS = tabulador, imprimir columnas 1..3
awk 'BEGIN{FS=","; OFS="	"} NR>1{print $1,$2,$3}' datos.csv
```

---

## 12) Procesar múltiples archivos
```bash
# Mostrar archivo y número de línea cuando $3 > 1700
awk -F',' 'NR==1{next} $3>1700{print FILENAME ":" FNR ":" $0}' *.csv
```

---

## 13) Casos prácticos frecuentes
```bash
# 13.1 Formatear CSV → tabla alineada
awk -F',' 'NR==1{print;next} {printf "%-10s %-8s %6.0f
",$1,$2,$3}' datos.csv

# 13.2 Extraer dominio de email
awk -F'@' '{print $2}' emails.txt | sort | uniq -c | sort -nr

# 13.3 Limpiar espacios extra (colapsar espacios internos)
awk '{gsub(/[[:space:]]+/," "); sub(/^ /,""); sub(/ $/,""); print}' texto.txt

# 13.4 Generar JSON simple por línea
awk -F',' 'NR>1{printf "{\"nombre\":\"%s\",\"pais\":\"%s\",\"sueldo\":%s}\n",$1,$2,$3}' datos.csv

# 13.5 Reemplazo por columna (no por regex)
awk -F',' 'BEGIN{OFS=","} {if($2=="Peru")$2="Perú"; print}' datos.csv
```

---

## 14) Mini‑ejercicios

1) De `datos.csv` (nombre,pais,sueldo), imprime solo **nombre y sueldo** con 2 decimales y encabezado propio.  
   *Pista:* `BEGIN`, `printf` y `NR>1`.

2) Calcula el **promedio de sueldo por país** (group‑by). Ordénalo de mayor a menor.  
   *Pista:* arreglo `total[pais]+=sueldo` y al final `for (...) print ... | sort -nr`.

3) Muestra solo filas donde el nombre sea “Ana” **y** el sueldo sea **>= 1800**.

4) Reemplaza en la salida (no en el archivo) la palabra `Mexico` por `México` solo en la **segunda columna**.

5) Crea una columna nueva con **sueldo+IVA (16%)** y muéstrala con 2 decimales.

---

## 15) Errores comunes
- Olvidar `-F','` para CSV y que el espacio sea el separador por defecto.
- Usar `print $1 $2` sin coma: se concatenan **sin espacio** (usa `print $1, $2` o configura `OFS`).
- Esperar salto de línea con `printf`: hay que poner `\n` manualmente.
- No saltar el encabezado: usa `NR>1` o `FNR>1` si procesas varios archivos.
- Problemas con acentos/UTF‑8: asegura tu `LC_ALL`, `LANG` o usa herramientas que respeten UTF‑8.

---

## 16) Referencia rápida
```bash
# Seleccionar columnas
awk -F',' '{print $1,$3}' datos.csv

# Filtrar por condición
awk -F',' '$3>1700{print $0}' datos.csv

# Saltar encabezado
awk -F',' 'NR>1{print $0}' datos.csv

# Suma / promedio
awk -F',' 'NR>1{s+=$3} END{print s, s/NR-1}' datos.csv   # ojo: NR-1 si hay encabezado

# Group-by
awk -F',' 'NR>1{t[$2]+=$3} END{for(k in t) print k,t[k]}' datos.csv

# Formato
awk -F',' 'NR>1{printf "%-12s %8.2f\n",$1,$3}' datos.csv

# Pasar variable
awk -F',' -v X=2000 'NR>1 && $3>=X{print $0}' datos.csv
```

---

## 17) Ordenar resultados
`awk` no ordena por sí mismo, pero puedes combinar con `sort`:
```bash
awk -F',' 'NR>1{t[$2]+=$3} END{for(k in t) print k,t[k]}' datos.csv | sort -k2,2nr
```
- `-k2,2nr` → ordena por la **columna 2**, numérico (`n`), descendente (`r`).

