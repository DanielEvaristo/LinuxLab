# 📂 LinuxLab

Este repositorio contiene una colección de **scripts** y **archivos generados** para aprender, documentar y explorar comandos de Linux.  
El objetivo es generar material de referencia y documentación en español que pueda ser usado como guía para la enseñanza y práctica de comandos.  

---

## 📁 Estructura del repositorio

- **`comandos_con_ayuda/`**  
  Carpeta que contiene archivos con listas de comandos y sus descripciones cortas, obtenidas con `whatis` y procesadas en español.  
  - Ejemplo: `comandos_con_a.txt` contiene todos los comandos que empiezan con la letra "a".

- **`comandos_por_letra/`**  
  Carpeta con listas de comandos por letra, sin descripción.  
  Útil para ver la cantidad de comandos disponibles y explorar uno por uno.

- **`ayuda_con_man.sh`**  
  Script para abrir la página de manual (`man`) de una lista de comandos.  

- **`comandos_basicos.md`**  
  Documento en español con explicación y ejemplos de comandos esenciales como `sed`, `grep`, `tr` y `awk`.  

- **`generar_comandos_con_ayuda.sh`**  
  Script que genera archivos con comandos y su descripción breve usando `whatis` (en español).  

- **`generar_comandos_por_letra.sh`**  
  Script que genera listas de comandos por letra.  

- **`todos_los_comandos_con_ayuda.txt`**  
  Archivo combinado con todos los comandos y descripciones en un solo documento.  

---

## 📜 Scripts principales

### 1. **`generar_comandos_por_letra.sh`**
Genera listas de comandos por cada letra (a-z) y los guarda en la carpeta `comandos_por_letra/`.  

```bash
bash generar_comandos_por_letra.sh
```

---

### 2. **`generar_comandos_con_ayuda.sh`**
Genera archivos con comandos y su descripción breve en español. Los resultados se guardan en `comandos_con_ayuda/`.  

```bash
bash generar_comandos_con_ayuda.sh
```

---

### 3. **`ayuda_con_man.sh`**
Lee una lista de comandos y abre la página de manual de cada uno.  

```bash
bash ayuda_con_man.sh
```

---

## 📚 Documentación incluida

- **`comandos_basicos.md`** contiene:
  - `sed`: Edición de texto en flujo.  
  - `grep`: Búsqueda de texto con patrones.  
  - `tr`: Sustitución o eliminación de caracteres.  
  - `awk`: Procesamiento y formateo de texto por columnas.  

Cada sección incluye:
- Descripción clara en español.  
- Ejemplos prácticos.  
- Opciones útiles.  

---

## 🚀 Cómo ejecutar todo el flujo

1. Generar listas de comandos por letra:
```bash
bash generar_comandos_por_letra.sh
```

2. Generar listas con descripción:
```bash
bash generar_comandos_con_ayuda.sh
```

3. Consultar documentación básica:
```bash
cat comandos_basicos.md
```

4. Abrir `man` de una lista de comandos:
```bash
bash ayuda_con_man.sh
```

---

## 📌 Próximos pasos

- Ampliar documentación con más comandos.  
- Agregar ejemplos más complejos y casos prácticos.  
- Incluir scripts para buscar y filtrar comandos según palabra clave.  
