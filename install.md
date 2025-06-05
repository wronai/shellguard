# 🛡️ LLM Guard Shell - INSTANT SETUP

## 🚀 INSTALACJA (30 sekund):

```bash
# Quick install:
curl -fsSL https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh | bash
```


## 🚀 INSTALACJA (4 kroki):
```bash
# 1. Pobierz shell (jeden plik!)
curl -o shellguard.sh https://raw.githubusercontent.com/wronai/shellguard/main/shellguard.sh

# 2. Zrób wykonywalny
chmod +x shellguard.sh

# 3. Aktywuj w tej sesji
source shellguard.sh

# 4. (Opcjonalne) Dodaj na stałe do .bashrc
echo "source $(pwd)/shellguard.sh" >> ~/.bashrc
```

**GOTOWE! Teraz masz pełną kontrolę nad LLM.**

## 🎯 JAK TO DZIAŁA:

### Zamiast normalnych komend, LLM używa kontrolowanych:

```bash
# ❌ PRZED (niebezpieczne):
rm -rf folder/          # Usunie wszystko bez pytania
python malicious.py     # Uruchomi niebezpieczny kod
git reset --hard HEAD   # Zniszczy zmiany

# ✅ PO (bezpieczne):
rm -rf folder/          # ZABLOKOWANE! "Use safe_rm"
python malicious.py     # ZABLOKOWANE! "Dangerous code detected"
git reset --hard HEAD   # ZABLOKOWANE! "Use force_git with backup"
```

### LLM automatycznie używa tych komend myśląc że to normalne narzędzia:

```bash
python myfile.py        # Sprawdza bezpieczeństwo + uruchamia
npm install react       # Auto-backup + instaluje
git commit -m "msg"     # Działa normalnie (bezpieczne)
```

## 🔥 KOMENDY DLA CIEBIE (USER):

### Sprawdzanie stanu:
```bash
status          # Pełny status systemu
health          # Sprawdza zdrowie projektu  
check           # Szybkie sprawdzenie (dla LLM)
```

### Bezpieczeństwo:
```bash
backup          # Ręczny backup
rollback        # Przywróć ostatni backup
emergency       # Awaryjny reset
```

### Override (gdy musisz):
```bash
safe_rm file            # Usuń z backupem
force_git reset --hard  # Git z backupem
force_python script.py  # Uruchom mimo ostrzeżeń
```

## 🤖 KOMUNIKACJA Z LLM:

### ✅ DOBRA sesja:
```
YOU: "Sprawdźmy status projektu"
LLM: status
[Output: ✅ SYSTEM OK]

YOU: "Stwórz plik calculator.py"  
LLM: [tworzy plik]

YOU: "Przetestuj plik"
LLM: python calculator.py
[Output: ✅ Syntax OK, Security OK]

YOU: "Zacommituj zmiany"
LLM: git add . && git commit -m "Add calculator"
[Działa normalnie]
```

### ❌ ZŁA sesja (ale system ratuje):
```
YOU: "Wyczyść katalog"
LLM: rm -rf *
[🚨 BLOCKED: Dangerous pattern detected: rm -rf]

YOU: "Ok, użyj bezpiecznej metody"
LLM: safe_rm oldfiles/
[✅ Creating backup first...]
```

## 🎪 PRZYKŁADY KONTROLI:

### Python Security:
```bash
# Plik ze złośliwym kodem:
echo "import os; os.system('rm -rf /')" > bad.py

# LLM próbuje uruchomić:
python bad.py
# 🚨 Dangerous Python code detected in: bad.py
# Content preview:
# 1:import os; os.system('rm -rf /')
# Use 'force_python bad.py' to run anyway
```

### Git Protection:
```bash
# LLM próbuje zrobić destrukcyjną operację:
git reset --hard HEAD~10
# 🚨 BLOCKED: Dangerous pattern detected: --hard
# Use 'force_git' if you really need this git command
```

### NPM Safety:
```bash
# Automatyczny backup przed instalacją:
npm install some-package
# 🔍 Installing new packages: some-package
# 📦 Creating backup before package installation...
# ✅ Git backup created
```

## 📊 MONITORING:

### Status w czasie rzeczywistym:
```bash
status
# 📊 LLM GUARD STATUS
# ==================================
# Health Score: 95/100 ✅
# Commands Blocked: 3
# Last Backup: backup_20241205_143022
# Session Started: 2024-12-05T14:25:33
```

### Health Check:
```bash
health
# 🔍 Checking project health...
# 🐍 Checking Python syntax...
# ✅ Syntax OK: calculator.py
# ✅ Syntax OK: utils.py
# 📦 Checking Node.js project...
# ✅ Valid package.json
# 🎉 Project health: GOOD (Score: 98/100)
```

## 🚨 AWARYJNE SYTUACJE:

### LLM narobił bałaganu:
```bash
emergency
# 🚨 EMERGENCY MODE
# This will rollback to last known good state
# Continue? (y/N): y
# 🔄 Rolling back changes...
# ✅ Git rollback completed
```

### Zbyt wiele zmian:
```bash
# System automatycznie ostrzega:
# ⚠️ WARNING: 12 files changed! Consider backup.
```

### Niebezpieczne logi:
```bash
# Jeśli system znajdzie ERROR w logach:
# ⚠️ Error logs found
# Health Score: 85/100 ⚠️
```

## 🎯 DLACZEGO TO DZIAŁA:

1. **LLM nie wie że jest kontrolowany** - myśli że używa normalnych komend
2. **Wszystko przechodzi przez proxy** - shell przechwytuje każdą komendę  
3. **Immediate feedback** - LLM widzi ✅ lub ❌ natychmiast
4. **Auto-backup** - każda ryzykowna operacja tworzy backup
5. **Pattern matching** - blokuje niebezpieczne wzorce automatycznie

## 🔧 ZAAWANSOWANE:

### Dodaj własne blokady:
```bash
block "dangerous_function("
# ✅ Added pattern to blocklist: dangerous_function(
```

### Background monitoring:
```bash
# Monitor uruchamia się automatycznie i co minutę sprawdza:
# - Czy nie zmieniło się za dużo plików
# - Czy nie ma błędów w logach  
# - Czy health score nie spada
```

### Custom patterns w ~/.shellguard/blocked.txt:
```
your_dangerous_pattern
another_bad_command
risky_operation
```

## 🎉 WYNIK:

- **Jeden plik** kontroluje wszystko
- **Zero konfiguracji** - działa od razu
- **LLM pod kontrolą** - nie może zrobić szkód
- **Automatyczny backup/rollback** - zawsze można cofnąć
- **Real-time feedback** - problemy wychwytywane natychmiast

**To jest to! Prosty, skuteczny, niezawodny.** 🎯

---

## 📱 QUICK REFERENCE:

```bash
# SETUP
source shellguard.sh

# DLA CIEBIE  
status health backup rollback emergency

# DLA LLM (automatyczne)
python npm git (wszystkie monitorowane)

# OVERRIDE
safe_rm force_git force_python

# HELP
llm_help
```

**ZAINSTALUJ RAZ - UŻYWAJ ZAWSZE!** 🚀