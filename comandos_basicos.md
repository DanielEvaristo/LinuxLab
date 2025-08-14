# 📘 Documentación básica de comandos

## 1. `sed` – *Editor de flujo (Stream EDitor)*  
**Descripción**:  
Permite buscar, reemplazar, eliminar o modificar texto sin abrir un editor. Trabaja línea por línea y se usa mucho en procesamiento de datos.

**Cómo funciona**:  
- Lee cada línea del archivo o entrada.
- Aplica la regla que le damos.
- Imprime el resultado (a menos que usemos `-i` para modificar el archivo directamente).

**Uso básico**:
```bash
sed 's/viejo/nuevo/' archivo.txt
```
Reemplaza **la primera aparición** de "viejo" por "nuevo" en cada línea.

**Opciones útiles**:
- `-i` → Edita el archivo directamente.
- `-n` y `p` → Muestra solo las líneas que cumplen el patrón.
- `s///g` → Reemplaza todas las coincidencias en la línea.

**Ejemplo práctico**:  
Archivo `errores.txt`:
```
error en la línea 1
otro error en la línea 2
```
Comando:
```bash
sed 's/error/ERROR/g' errores.txt
```
Salida:
```
ERROR en la línea 1
otro ERROR en la línea 2
```

---

## 2. `grep` – *Buscar texto con expresiones regulares*  
**Descripción**:  
Busca patrones de texto en archivos o en la entrada estándar. Puede trabajar con texto normal o expresiones regulares.

**Cómo funciona**:  
- Lee el archivo línea por línea.
- Compara con el patrón.
- Muestra las líneas que coinciden.

**Uso básico**:
```bash
grep "texto" archivo.txt
```
Muestra las líneas donde aparezca "texto".

**Opciones útiles**:
- `-i` → Ignora mayúsculas/minúsculas.
- `-r` → Busca en carpetas recursivamente.
- `-n` → Muestra el número de línea.
- `-v` → Muestra líneas que **no** coinciden.

**Ejemplo práctico**:
```bash
grep -in "error" *.log
```
Busca "error" en todos los `.log`, sin importar mayúsculas, mostrando el número de línea.

---

## 3. `tr` – *Traducir o eliminar caracteres*  
**Descripción**:  
Convierte o elimina caracteres de la entrada. Trabaja siempre con **entrada estándar** (pipes o redirecciones).

**Cómo funciona**:  
- Recibe texto.
- Sustituye caracteres por otros o los elimina.

**Uso básico**:
```bash
echo "hola mundo" | tr 'a-z' 'A-Z'
```
Convierte minúsculas a mayúsculas.

**Opciones útiles**:
- `-d` → Elimina caracteres.
- `-s` → Reduce caracteres repetidos a uno solo.

**Ejemplos prácticos**:
Eliminar espacios extra:
```bash
echo "hola    mundo" | tr -s ' '
```
Eliminar números:
```bash
echo "abc123" | tr -d '0-9'
```

---

## 4. `awk` – *Procesador y formateador de texto*  
**Descripción**:  
Un lenguaje para trabajar con datos en columnas. Permite filtrar, calcular y dar formato.

**Cómo funciona**:  
- Lee cada línea.
- Divide en columnas usando un separador.
- Ejecuta una acción.

**Uso básico**:
```bash
awk '{print $1}' archivo.txt
```
Muestra la primera columna.

**Opciones útiles**:
- `-F` → Define el separador.
- `$1`, `$2`… → Columnas.
- `NR` → Número de línea.

**Ejemplo práctico**:  
Archivo `datos.csv`:
```
Juan,25,México
Ana,30,Chile
```
Comando:
```bash
awk -F',' '{print $1, $3}' datos.csv
```
Salida:
```
Juan México
Ana Chile
```

---

💡 **Consejo**  
Puedes combinar comandos con **pipes** (`|`) para hacer flujos más potentes.

Ejemplo:
```bash
grep "error" log.txt | sed 's/error/ERROR/' | awk '{print $1, $2}'
```
Busca "error", lo pone en mayúsculas y muestra solo la primera y segunda columna.
