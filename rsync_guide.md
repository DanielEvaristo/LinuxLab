# Guía práctica de **rsync** (sincronización y copia eficiente)

> Copia/sincroniza carpetas **locales o remotas** preservando permisos y fechas, con transferencias incrementales y reanudables.

---

## 1) ¿Qué es `rsync`?
`rsync` compara **origen → destino** y transfiere solo lo necesario (diferencias). Puede trabajar:
- **Local → local**
- **Local → remoto** (vía **SSH**)
- **Remoto → local** (vía **SSH**)

Usa un algoritmo delta (bloques) y metadatos (tamaño/mtime) para decidir qué copiar. Con `-c` puede usar **checksum** (más lento, más exacto).

---

## 2) Sintaxis básica
```bash
# Local → local
rsync [opciones] ORIGEN DESTINO

# Local → remoto (sobre SSH)
rsync [opciones] ORIGEN usuario@host:/ruta/remota/

# Remoto → local (sobre SSH)
rsync [opciones] usuario@host:/ruta/remota/ DESTINO
```

**Opciones clave (chuleta):**
| Opción | Qué hace |
|------:|:---------|
| `-a` | **archive**: recursivo y preserva `-rlptgoD` (perms, tiempos, grupos, dueños, dispositivos). |
| `-v` | verbose (muestra detalle). |
| `-h` | tamaños legibles (human). |
| `-z` | comprime durante la transferencia. |
| `-P` | equivale a `--partial --progress` (reanudable + progreso). |
| `--delete` | borra en destino lo que ya no existe en origen. |
| `--exclude`/`--include` | patrones para excluir/incluir. |
| `-e 'ssh ...'` | usa ssh y permite pasar puerto/opciones. |
| `-n` | **dry‑run** (simula sin cambiar nada). |
| `-c` | compara por checksum (lento, exacto). |
| `-H` | preserva hardlinks (más costoso). |
| `-S` | almacena archivos dispersos como sparse. |

> ⚠️ **Barra final importa**:  
> - `rsync src/ dst/` → copia **contenido** de `src/` dentro de `dst/`  
> - `rsync src dst/`   → crea `dst/src`

---

## 3) Ejemplos rápidos

### 3.1 Sincronización local (con preservación y progreso)
```bash
rsync -avhP --delete carpeta_origen/ carpeta_destino/
```

### 3.2 Copia por SSH (puerto 2222, comprimiendo)
```bash
rsync -avz -e 'ssh -p 2222' ./proyecto/ usuario@server:/srv/proyecto/
```

### 3.3 Traer backup remoto → local (solo `.tar.gz`)
```bash
rsync -av --include='*.tar.gz' --exclude='*' usuario@server:/backups/ ./backups_local/
```

### 3.4 Excluir cosas típicas (.git, node_modules, cachés)
```bash
rsync -av --exclude='.git/' --exclude='node_modules/' --exclude='*.cache' src/ dst/
# o desde un archivo
rsync -av --exclude-from='.rsyncignore' src/ dst/
```

### 3.5 Simular antes de ejecutar (seguro)
```bash
rsync -avh --delete -n src/ dst/   # muestra qué pasaría
```

### 3.6 Sincronización “mirroring” (destino réplica exacta)
```bash
rsync -avh --delete src/ dst/
# cuidado: borra en destino lo que no exista en origen
```

### 3.7 Restringir ancho de banda (ej. 2 MB/s)
```bash
rsync -av --bwlimit=2000 src/ dst/
```

### 3.8 Reanudar transferencias grandes
```bash
rsync -avP src/ dst/        # --partial --progress
```

### 3.9 Forzar comparación por checksum (integridad sobre velocidad)
```bash
rsync -avc src/ dst/
```

---

## 4) Incluir/Excluir con patrones

Orden de evaluación: `--include` y `--exclude` se procesan en **secuencia**. Un patrón que **incluye** un directorio debe ir **antes** que el patrón que excluye todo.

```bash
# Solo sincronizar *.jpg dentro de imágenes, ignorando el resto
rsync -av   --include='imagenes/' --include='imagenes/**/*.jpg'   --exclude='*'   src/ dst/
```

**Consejos:**
- Termina directorios con `/` en patrones (`'tmp/'`).
- Usa `--exclude-from=archivo` para mantener tu lista.

---

## 5) Seguridad, permisos y dueños
- `-a` preserva permisos/propietarios. Para preservar **propietario/grupo** en destino necesitas permisos de **root** (o sudo) allí.
- Para seguir symlinks (copiar el archivo apuntado) usa `-L`. Con `-a` por defecto preserva el **symlink** como tal.
- Si te preocupa la integridad final, añade `-c` (checksum).

---

## 6) Copias con historial (versionado simple)
Con `--backup` y `--backup-dir=DIR` puedes **mover** versiones reemplazadas/borradas a una carpeta de histórico (fecha útil):
```bash
FECHA=$(date +%F_%H%M)
rsync -av --delete --backup --backup-dir="hist/$FECHA" src/ dst/
```
Esto deja `dst/` como espejo y guarda lo que cambió en `dst/hist/FECHA/`.

---

## 7) Buenas prácticas
- Siempre prueba con **`-n` (dry‑run)** antes de usar `--delete`.
- Usa `-P` en redes inestables para reanudar.
- En conexiones lentas, añade `-z` (compresión).
- En scripts/cron, **cita rutas** y usa rutas absolutas.
- Controla el **retorno**: `|| echo "falló rsync"` para manejar errores.
- Si sincronizas millones de archivos, valora empaquetar (tar) o usar `--info=progress2`.

---

## 8) Mini‑ejercicios (hazlos y comenta resultados)

1) Crea dos carpetas (`origen/`, `destino/`) con algunos archivos y sincroniza con:
```bash
rsync -avhP --delete origen/ destino/
```
¿Notas qué borra en destino si eliminas algo en origen y repites el comando?

2) Simula subir `./proyecto/` a un servidor en el puerto 2200 **sin ejecutar cambios**:
```bash
rsync -avz -e 'ssh -p 2200' -n ./proyecto/ user@mi.host:/srv/proyecto/
```

3) Solo copia `.jpg` y `.png` desde `media/` y excluye el resto:
```bash
rsync -av --include='*.jpg' --include='*.png' --exclude='*' media/ dest_media/
```

4) Haz un “mirror” de `datos/` en `copia/` y guarda los reemplazos en una carpeta con fecha:
```bash
FECHA=$(date +%F_%H%M)
rsync -av --delete --backup --backup-dir="cambios/$FECHA" datos/ copia/
```

5) Limita la transferencia a **1 MB/s** y muestra progreso global:
```bash
rsync -av --bwlimit=1000 --info=progress2 origen/ destino/
```

---

## 9) Referencia rápida
```bash
# Básico y seguro (simular primero)
rsync -avh -n src/ dst/

# Mirror (réplica exacta)
rsync -avh --delete src/ dst/

# SSH y compresión
rsync -avz -e 'ssh -p 2222' dir/ user@host:/ruta/

# Incluir/Excluir
rsync -av --exclude-from='.rsyncignore' src/ dst/

# Reanudar + progreso
rsync -avP src/ dst/

# Checksum (integridad > velocidad)
rsync -avc src/ dst/
```
