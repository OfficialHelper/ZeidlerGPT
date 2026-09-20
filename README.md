# ZeidlerGPT V3.0.1

ZeidlerGPT ist eine installierbare Windows-Desktop-Anwendung auf Basis von **Electron + React + SQLite**. Die App besitzt einen lokalen Benutzer-/Rollenbereich, Chatverlauf, Gemini-Streaming, sichere API-Key-Speicherung, Markdown, Suchfunktion, Favoriten/Archiv und ein technisch geschütztes Administrator-Panel.

## 1. Voraussetzungen

Empfohlen:

- Windows 10 oder Windows 11 (64 Bit)
- Aktuelle Node.js-LTS-Version (Node.js 22 oder neuer)
- npm
- Internetverbindung für Gemini-Antworten
- Eigener Gemini API-Key

Der eigentliche Windows-Installer wird am zuverlässigsten **unter Windows** gebaut, weil `better-sqlite3` ein natives Node-Modul enthält und Electron Builder dafür die zur Zielplattform passenden Binärdateien vorbereitet.

## 2. Node.js installieren

1. Installiere die aktuelle LTS-Version von Node.js.
2. Öffne danach PowerShell oder die Eingabeaufforderung.
3. Prüfe:

```powershell
node --version
npm --version
```

## 3. Projekt installieren

Entpacke den Projektordner und öffne in diesem Ordner ein Terminal:

```powershell
cd ZeidlerGPT-V3.0.1
npm install
```

`postinstall` führt anschließend `electron-builder install-app-deps` aus, damit das native SQLite-Modul zur verwendeten Electron-Version passt.

## 4. Abhängigkeiten

Wichtige Pakete:

- `electron` – Desktop-Runtime
- `react` / `react-dom` – Benutzeroberfläche
- `vite` – Renderer-Build
- `better-sqlite3` – lokale SQLite-Datenbank
- `@google/genai` – offizielle Gemini-JavaScript-SDK
- `react-markdown` + `remark-gfm` – Markdown/Tabellen/Codeblöcke
- `electron-builder` – Windows-Installer/Portable-Build

## 5. Gemini API-Key

Der Gemini API-Key wird **nicht** in React, `.env` oder im gebauten Renderer hinterlegt.

Nach dem Start:

1. `Einstellungen`
2. `KI`
3. API-Key eingeben
4. `Speichern`
5. Optional `Testen`

Die App verschlüsselt den Key mit Electron `safeStorage` und speichert nur den verschlüsselten Wert in der lokalen SQLite-Datenbank. Im Renderer wird nur eine Maskierung wie `••••••••••••ABCD` angezeigt.

Das Standardmodell ist `gemini-3.8-flash`. Über das Admin-Panel können weitere gültige Gemini-Modell-IDs freigegeben werden.

### Denkmodus und Denkstärke

- **Denkmodus: Automatisch** – es wird kein erfundener Zeit-/Thinking-Parameter gesetzt; Gemini verwendet sein dynamisches Standardverhalten.
- **Denkmodus: Gesteuert** – ZeidlerGPT verwendet den offiziellen `thinkingLevel`.
- Schnell → `low`
- Ausgewogen → `medium`
- Tief → `high`
- Sehr tief → `high` plus zusätzliche Sorgfaltsanweisung im Systemkontext, weil Gemini 3.8 Flash offiziell nur `low`, `medium` und `high` unterstützt.

`Antwortaufwand` ist ausdrücklich **keine echte Zeitbegrenzung**. Er verändert nur die gewünschte Arbeits-/Detailtiefe der Antwort.

## 6. Entwicklungsmodus

```powershell
npm run dev
```

Das startet Vite und danach Electron. Electron lädt im Entwicklungsmodus ausschließlich `http://127.0.0.1:5173`.

## 7. Produktions-Build des Renderers

```powershell
npm run build
```

Der React/Vite-Build wird in `dist/` erstellt.

Danach kann die bereits gebaute App lokal mit Electron gestartet werden:

```powershell
npm start
```

## 8. Windows-Installer bauen

NSIS + portable EXE:

```powershell
npm run dist
```

Nur Installer:

```powershell
npm run dist:nsis
```

Nur portable EXE:

```powershell
npm run dist:portable
```

Die fertigen Dateien landen unter:

```text
dist-installer/
```

Der NSIS-Installer erstellt einen Startmenü-Eintrag, kann ZeidlerGPT deinstallieren und legt gemäß Build-Konfiguration eine Desktop-Verknüpfung an.

## 9. Datenbank

ZeidlerGPT erzeugt beim ersten Start automatisch:

```text
zeidlergpt.db
```

im Electron-`userData`-Verzeichnis des angemeldeten Windows-Benutzers.

Gespeichert werden:

- Rollen
- Benutzer
- Chats
- Nachrichten
- Benutzereinstellungen
- App-/Admin-Einstellungen
- verschlüsselte Secrets
- Audit-/Fehlerlogs

SQLite läuft mit Foreign Keys und WAL-Modus.

## 10. Admin-Account

Beim **allerersten Start** existiert noch kein Konto. Deshalb erscheint die Ersteinrichtung.

1. Benutzername eingeben
2. Passwort mit mindestens 10 Zeichen wählen
3. Passwort wiederholen
4. `ZeidlerGPT einrichten`

Das erste Konto erhält die Rolle `administrator`.

Das Admin-Panel ist nicht nur visuell versteckt: jede Admin-IPC-Funktion prüft zusätzlich im Electron-Main-Prozess, ob die aktuell angemeldete Rolle wirklich `administrator` ist.

### Rollen

- `user` – normaler Zugriff
- `moderator` – reservierte erweiterte Rolle ohne Zugriff auf das geschützte Administrator-Panel
- `administrator` – vollständiger Admin-Zugriff

Die App verhindert, dass der letzte aktive Administrator deaktiviert, gelöscht oder herabgestuft wird.

### Admin-Funktionen

- reale lokale Benutzer-/Chat-/Nachrichten-/API-/Fehlerzähler
- Benutzer anlegen
- Benutzer aktivieren/deaktivieren
- Rollen ändern
- Benutzer löschen
- Standardmodell verwalten
- erlaubte Gemini-Modelle verwalten
- System-Prompt ändern
- Output-Limit konfigurieren
- Anfragen/Minute konfigurieren
- maximales Nachrichtenlimit konfigurieren
- Markdown/Regenerieren/externe Links global aktivieren oder deaktivieren
- Audit-Logs ansehen

## 11. Sicherheit

Implementiert sind unter anderem:

- `nodeIntegration: false`
- `contextIsolation: true`
- Renderer-Sandbox
- restriktive Content Security Policy
- gefilterte `contextBridge`-API statt direktem `ipcRenderer`
- Prüfung der IPC-Absender-URL
- rollenbasierte Autorisierung im Main-Prozess
- `scrypt` + zufälliger Salt für Passwörter
- `safeStorage` für den Gemini-Key
- keine API-Keys in Renderer/Chat/Logs
- Linköffnung nur nach Sicherheitsdialog
- nur `http:` / `https:` für externe Links
- blockierte fremde Navigation und neue Fenster
- Eingabegrößenlimits
- einfaches lokales Rate-Limiting
- Datenbank-Parameterbindung über `better-sqlite3`

## 12. Auto-Update-Architektur

`electron/update.cjs` enthält eine getrennte Update-Schnittstelle. In V3.0.1 werden absichtlich **keine Dateien automatisch heruntergeladen**, weil kein vertrauenswürdiger signierter Update-Provider konfiguriert ist. Dadurch wird kein unsicherer Auto-Updater simuliert.

## 13. Offline-Modus

Ohne Internet können lokale Chats, Einstellungen und das Admin-Panel weiterhin geöffnet werden. KI-Anfragen zeigen eine verständliche Fehlermeldung, weil Gemini eine Internetverbindung benötigt.

## 14. Fehlerbehebung

### `better-sqlite3` / native module passt nicht zu Electron

Im Projektordner ausführen:

```powershell
npx electron-builder install-app-deps
```

Danach erneut:

```powershell
npm run dev
```

### Ungültiger API-Key

Unter `Einstellungen → KI` den Key neu speichern und `Testen` drücken.

### Modell nicht verfügbar

Als Administrator unter `Admin-Panel → KI-Verwaltung` eine aktuell verfügbare Gemini-Modell-ID eintragen und als Standardmodell auswählen.

### Keine Internetverbindung

Lokale Daten funktionieren weiterhin. Für KI-Antworten muss die Verbindung zur Gemini API wieder verfügbar sein.

### Build-Probleme unter Linux/macOS für Windows

Wegen nativer Abhängigkeiten den finalen Windows-Build am besten direkt auf Windows 10/11 ausführen.

## 15. Projektstruktur

```text
ZeidlerGPT-V3.0.1/
├─ electron/
│  ├─ auth.cjs
│  ├─ db.cjs
│  ├─ gemini.cjs
│  ├─ main.cjs
│  ├─ preload.cjs
│  └─ update.cjs
├─ src/
│  ├─ components/
│  ├─ lib/
│  ├─ pages/
│  ├─ App.jsx
│  ├─ main.jsx
│  └─ styles.css
├─ assets/
│  ├─ icon.ico
│  └─ icon.png
├─ scripts/
│  └─ smoke-check.mjs
├─ index.html
├─ package.json
├─ vite.config.js
├─ .env.example
└─ README.md
```

## 16. Wichtige offizielle Referenzen

- Gemini API: `https://ai.google.dev/gemini-api/docs`
- Gemini Modelle: `https://ai.google.dev/gemini-api/docs/models`
- Electron Security: `https://www.electronjs.org/docs/latest/tutorial/security`
- Electron Context Isolation: `https://www.electronjs.org/docs/latest/tutorial/context-isolation`

