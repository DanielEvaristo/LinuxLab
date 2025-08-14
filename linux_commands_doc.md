# Basic Command Documentation

## 1. `sed` – *Stream EDitor*
**Description**: Tool to search, replace, delete, or modify text on the fly without opening an editor.

**Basic usage**:
```bash
sed 's/old/new/' file.txt
```
Replaces the first occurrence of "old" with "new" in each line.

**Useful options**:
- `-i` → Edit the file in place.
- `-n` and `p` → Print only matching lines.
- `s///g` → Perform a global replacement in each line.

**Example**:
```bash
sed 's/error/ERROR/g' log.txt
```

---

## 2. `grep` – *Global Regular Expression Print*
**Description**: Searches for text within files using patterns or regular expressions.

**Basic usage**:
```bash
grep "text" file.txt
```

**Useful options**:
- `-i` → Ignore case.
- `-r` → Search recursively in directories.
- `-n` → Show line number.
- `-v` → Invert match (show lines that do NOT match).

**Example**:
```bash
grep -in "error" *.log
```

---

## 3. `tr` – *Translate or delete characters*
**Description**: Converts or deletes characters from the input.

**Basic usage**:
```bash
tr 'a-z' 'A-Z'
```
Converts lowercase letters to uppercase.

**Useful options**:
- `-d` → Delete characters.
- `-s` → Squeeze repeated characters.

**Examples**:
```bash
echo "hello world" | tr 'a-z' 'A-Z'
echo "hello    world" | tr -s ' '
```

---

## 4. `awk` – *Pattern scanning and processing language*
**Description**: A powerful language for filtering, processing, and formatting text in columns.

**Basic usage**:
```bash
awk '{print $1}' file.txt
```
Prints the first column of each line.

**Useful options**:
- `-F` → Specify a field delimiter.
- Variables: `$1`, `$2`, etc. → Columns.
- `NR` → Line number.

**Example**:
```bash
awk -F',' '{print $1, $3}' data.csv
```

---

## Tip
These commands can be combined with pipes (`|`) to create powerful workflows.

**Example**:
```bash
grep "error" log.txt | sed 's/error/ERROR/' | awk '{print $1, $2}'
```
