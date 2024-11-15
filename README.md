Hier ist eine vollständige Erklärung des Skripts, das die Befehle `givecar`, `deletecar`, `listcars` und `storecar` beinhaltet, sowie die Integration von Discord-Logs und Chat-Befehlsvorschlägen:

### **Ziel des Skripts**
Das Skript ermöglicht es Admins, Fahrzeugbefehle über die Konsole oder den Chat auszuführen. Es enthält vier Hauptbefehle, die es einem Admin ermöglichen,:
1. Ein Fahrzeug an einen Spieler zu übergeben (`givecar`).
2. Ein Fahrzeug aus der Datenbank zu löschen (`deletecar`).
3. Eine Liste der Fahrzeuge eines Spielers anzuzeigen (`listcars`).
4. Den Speicherstatus eines Fahrzeugs zu ändern (`storecar`).

Zusätzlich werden alle Änderungen an Fahrzeugen in einen Discord-Webhook-Log gesendet, und es werden Chat-Befehlsvorschläge hinzugefügt, um die Benutzererfahrung zu verbessern.

---

### **Befehlserklärungen und -verwendung**

#### **1. `/givecar [Spieler-ID] [Fahrzeug-Modell] [Typ]`**
- **Beschreibung:** Gibt einem Spieler ein Fahrzeug.
- **Argumente:**
  - **Spieler-ID**: Die ID des Spielers, dem das Fahrzeug gegeben werden soll.
  - **Fahrzeug-Modell**: Der Modellname des Fahrzeugs, z. B. `"adder"`.
  - **Typ (optional)**: Der Fahrzeugtyp, z. B. `"car"`, `"boat"`, `"plane"`. Wenn nicht angegeben, wird standardmäßig `"car"` verwendet.
- **Vorgehensweise:** Das Fahrzeug wird dem Spieler zugewiesen und in der Datenbank gespeichert.

#### **2. `/deletecar [Kennzeichen]`**
- **Beschreibung:** Löscht ein Fahrzeug aus der Datenbank anhand des Kennzeichens.
- **Argumente:**
  - **Kennzeichen**: Das Kennzeichen des Fahrzeugs, das gelöscht werden soll.
- **Vorgehensweise:** Löscht das Fahrzeug mit dem angegebenen Kennzeichen aus der Datenbank.

#### **3. `/listcars [Spieler-ID]`**
- **Beschreibung:** Zeigt alle Fahrzeuge eines Spielers an.
- **Argumente:**
  - **Spieler-ID**: Die ID des Spielers, dessen Fahrzeuge angezeigt werden sollen.
- **Vorgehensweise:** Holt die Fahrzeuge des Spielers aus der Datenbank und zeigt sie im Chat an.

#### **4. `/storecar [Kennzeichen] [0/1]`**
- **Beschreibung:** Ändert den Speicherstatus eines Fahrzeugs.
- **Argumente:**
  - **Kennzeichen**: Das Kennzeichen des Fahrzeugs, dessen Speicherstatus geändert werden soll.
  - **Status (0/1)**: Gibt an, ob das Fahrzeug eingelagert (1) oder ausgelagert (0) ist.
- **Vorgehensweise:** Setzt den Speicherstatus des Fahrzeugs in der Datenbank.

---

### **Discord-Webhook-Integration**
Für jede Änderung an einem Fahrzeug wird eine Nachricht an einen Discord-Webhook gesendet, um diese Änderungen zu protokollieren. Die Nachricht enthält Details wie:
- Der Admin, der den Befehl ausgeführt hat.
- Die Art der Änderung (z. B. Fahrzeug hinzugefügt oder gelöscht).
- Zusätzliche Details wie Fahrzeugmodell und Kennzeichen.

**Beispiel einer Discord-Nachricht:**
```
Fahrzeug hinzugefügt:
Admin: Max Mustermann
Fahrzeug: Adder (Kennzeichen: CAR1234)
Zielspieler: Jane Doe
```

---

### **Chat-Befehlsvorschläge**
Das Skript fügt **Befehlsvorschläge** im Chat hinzu, die es den Spielern ermöglichen, die korrekte Syntax der Befehle zu sehen, ohne die Dokumentation zu durchsuchen. Die Spieler können beim Eingeben eines Befehls eine automatische Hilfe erhalten, die ihnen zeigt, welche Argumente sie angeben müssen.

**Beispiel eines Befehlsvorschlags im Chat:**
- `/givecar` Vorschläge: `Spieler-ID`, `Fahrzeug-Modell`, `Fahrzeugtyp`
- `/deletecar` Vorschläge: `Kennzeichen`
- `/listcars` Vorschläge: `Spieler-ID`
- `/storecar` Vorschläge: `Kennzeichen`, `Status (0 oder 1)`

---

### **Code-Details**

#### **Wichtige Teile des Codes**

1. **`ESX` Initialisierung:**
   Das Skript verwendet die `ESX`-Bibliothek, um mit dem Framework zu interagieren. Der `getSharedObject`-Event wird aufgerufen, um ESX verfügbar zu machen.

2. **`oxmysql` für Datenbankoperationen:**
   - Die Datenbankoperationen verwenden `oxmysql`, um mit der MySQL-Datenbank zu interagieren, speziell um Fahrzeuge zu erstellen, zu löschen und deren Status zu ändern.
   - `oxmysql:insert` wird verwendet, um ein Fahrzeug in die Datenbank einzufügen.
   - `oxmysql:execute` wird verwendet, um einen bestehenden Datensatz zu löschen oder zu aktualisieren.

3. **Discord Webhook:**
   - Eine Funktion `sendToDiscord` sendet Ereignisse an einen Discord-Webhook.
   - Der Webhook-URL wird in einer Variablen gespeichert. Du musst deine eigene URL hier einfügen.

4. **Befehlsvorschläge:**
   - Die `chat:addSuggestion`-Funktion wird verwendet, um dem Chat Befehlsvorschläge hinzuzufügen.
   - Diese Vorschläge zeigen den Spielern, welche Parameter sie für jeden Befehl eingeben können.

---

### **Voraussetzungen**
- **ESX** muss installiert und korrekt konfiguriert sein.
- **oxmysql** muss als Datenbank-Verbindungslösung verwendet werden.
- **Discord Webhook-URL**: Du musst deine eigene Discord-Webhook-URL in der `sendToDiscord`-Funktion angeben.
- **MySQL-Datenbankstruktur**: Du musst sicherstellen, dass die Tabelle `owned_vehicles` mit den entsprechenden Feldern existiert, um Fahrzeugdaten zu speichern.

---

### **Beispiel für die MySQL-Tabelle `owned_vehicles`:**
```sql
CREATE TABLE `owned_vehicles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `owner` VARCHAR(255) NOT NULL,
  `plate` VARCHAR(10) NOT NULL,
  `vehicle` TEXT NOT NULL,
  `stored` INT(1) DEFAULT 1,
  `type` VARCHAR(50) DEFAULT 'car'
);
```

---

### **Erklärung der wichtigsten Funktionen:**

1. **`sendToDiscord` Funktion:** 
   Diese Funktion sendet Protokollnachrichten an Discord, wenn ein Fahrzeug hinzugefügt oder gelöscht wird, oder wenn der Speicherstatus geändert wird.

2. **Fahrzeug-Übergabe mit `/givecar`:**
   Der Befehl `/givecar` fügt das Fahrzeug des angegebenen Spielers zur `owned_vehicles`-Tabelle in der MySQL-Datenbank hinzu. Der Spieler erhält das Fahrzeug und wird darüber informiert.

3. **Fahrzeug-Löschung mit `/deletecar`:**
   Der Befehl `/deletecar` löscht das Fahrzeug basierend auf dem Kennzeichen aus der Datenbank. Wenn erfolgreich, wird eine Bestätigung im Chat angezeigt.

4. **Fahrzeug-Liste mit `/listcars`:**
   Der Befehl `/listcars` holt alle Fahrzeuge eines Spielers aus der Datenbank und zeigt sie im Chat an.

5. **Fahrzeugstatus ändern mit `/storecar`:**
   Der Befehl `/storecar` ändert den Speicherstatus eines Fahrzeugs. Der Status wird auf `1` gesetzt, wenn es eingelagert ist, oder auf `0`, wenn es ausgelagert ist.

---

### **Zusammenfassung:**
Dieses Skript stellt Admins eine Vielzahl von Werkzeugen zur Verfügung, um die Verwaltung von Fahrzeugen zu erleichtern. Mit der Möglichkeit, Fahrzeuge zu erstellen, zu löschen und deren Status zu ändern, kombiniert mit einem Discord-Logging-Mechanismus, wird eine effiziente Verwaltung ermöglicht. Die zusätzlichen Chat-Befehlsvorschläge verbessern die Benutzererfahrung und erleichtern die Nutzung der Befehle für Admins.

Wenn du noch weitere Fragen hast oder zusätzliche Funktionen benötigst, lass es mich wissen! 😊
