
---

# Greenshot OCR Integration Using Capture2Text with English & Norwegian 

**Supports English + Norwegian OCR with OneBlock & LineBreak modes. Other languages is supported too!**

---

## 📦 1. Installation Folder

Extract `Capture2Text` to:

```
C:\Capture2Text\
```

You must see this layout:

```
C:\Capture2Text\
├── Capture2Text.exe
├── Capture2Text_CLI.exe
├── tessdata\
│   ├── eng.traineddata
│   └── nor.traineddata
```

Do **not** rename the folder or move files later.

---

## 🌐 2. Install OCR Language Files 
### These steps (step 2 & 3) can be skipped if the language you want already exist in the tessdata folder below.
https://github.com/tesseract-ocr/tessdata

1. Place `eng.traineddata` (English) and `nor.traineddata` (Norwegian) into:

```
C:\Capture2Text\tessdata\
```

2. Files must be named **exactly** as above (no `.txt`, no uppercase).

---

## 🧠 3. Register OCR Languages via GUI 

> ⚠️ If you skip this, CLI-based OCR **will fail** with `Error, specified OCR language not found.`

### Steps:

1. Run:

   ```
   C:\Capture2Text\Capture2Text.exe
   ```

2. Right-click the tray icon → **OCR Language**
   Select:

   * `English`
   * `Norwegian` (if not visible, check spelling or recheck traineddata name)

3. Then exit the tray app (right-click → Exit)

✅ This updates the internal config so the CLI can use these languages.

---

## ⚙️ 4. Greenshot Plugin Setup (External Command)

### Open:

Greenshot Tray icon → Preferences → Plugins →
**External Command Plugin** → Configure

Now click **Add** and fill in each of the 4 blocks below:

---

### 🔹 English OneBlock

* **Menu item name:**

  ```
  OCR to Clipboard - English OneBlock
  ```

* **Command:**

  ```
  C:\Capture2Text\Capture2Text_CLI.exe
  ```

* **Arguments:**

  ```
  -i "{0}" --clipboard -l English
  ```

---

### 🔹 English LineBreak

* **Menu item name:**

  ```
  OCR to Clipboard - English LineBreak
  ```

* **Command:**

  ```
  C:\Capture2Text\Capture2Text_CLI.exe
  ```

* **Arguments:**

  ```
  -i "{0}" --clipboard -line-breaks -l English
  ```

---

### 🔹 Norwegian OneBlock

* **Menu item name:**

  ```
  OCR to Clipboard - Norwegian OneBlock
  ```

* **Command:**

  ```
  C:\Capture2Text\Capture2Text_CLI.exe
  ```

* **Arguments:**

  ```
  -i "{0}" --clipboard -l Norwegian
  ```

---

### 🔹 Norwegian LineBreak

* **Menu item name:**

  ```
  OCR to Clipboard - Norwegian LineBreak
  ```

* **Command:**

  ```
  C:\Capture2Text\Capture2Text_CLI.exe
  ```

* **Arguments:**

  ```
  -i "{0}" --clipboard -line-breaks -l Norwegian
  ```

---

## 💡 5. Explanation of Arguments

| Option          | Meaning                                              |
| --------------- | ---------------------------------------------------- |
| `-i "{0}"`      | Automatically insert image path from Greenshot       |
| `--clipboard`   | Copy OCR text to clipboard                           |
| `-line-breaks`  | (optional) Preserves original line breaks in text    |
| `-l [Language]` | OCR language to use (case-sensitive, GUI-registered) |

---

## 🧪 6. How to Test It

1. Restart Greenshot & take a screenshot with Greenshot
2. Choose one of the new plugin entries
3. Press `Ctrl + V` in Notepad

You should see the OCR'd text, correctly recognized and formatted.

---

## 🛠️ 7. Common Errors and Fixes

### ❌ `Error, specified OCR language not found.`

**Cause:** Language not activated in GUI

**Fix:**

* Run `Capture2Text.exe`
* Right-click tray → OCR Language → Select your language
* Exit tray icon

### ❌ No text copied to clipboard

* Ensure `--clipboard` is present in arguments
* Ensure screenshot actually contains visible text

### ❌ OCR garbage output

* Wrong language selected
* Poor image resolution or contrast
* Missing traineddata file


