<div align="center">
  <h2>Choose your language please</h2>
  <h1> 🇫🇷 <a href="#fr">FR</a> / 🇬🇧 <a href="#en">EN</a></h1>
</div>

---

<a id="fr"></a>

# Auto-Disable Bluetooth Hands-Free Telephony on Windows

## 🎯 Objectif

Certains casques Bluetooth apparaissent dans Windows avec deux profils audio :

- **A2DP (Stereo)** → audio de bonne qualité
- **HFP/HSP (Hands-Free Telephony)** → micro activé mais qualité audio médiocre

Par défaut, Windows peut basculer automatiquement sur le profil "Hands-Free Telephony" lorsque le casque se connecte, ce qui casse la qualité sonore.  
Ce script automatise la désactivation du service HFP **à chaque connexion du casque**.

---

## ⚙️ Prérequis

- **PowerShell** (inclus avec Windows 10/11)
- **Bluetooth Command Line Tools** installé et disponible dans le `PATH`  
  👉 [Bluetooth Command Line Tools](https://bluetoothinstaller.com/bluetooth-command-line-tools)

---

## 📜 Script PowerShell

Créer un fichier `Disable-HFP.ps1` avec le contenu suivant :

```powershell
# === CONFIGURATION ===
$targetDevices = @(
    "JBL TUNE760NC",
    "CMF Buds"
)

# Nom de la commande btcom (adapter si le chemin complet est nécessaire, ex: C:\BluetoothTools\btcom.exe)
$btcom = "btcom"

foreach ($device in $targetDevices) {
    # Vérifie si l’appareil Bluetooth est présent et connecté
    $status = Get-PnpDevice | Where-Object {
        $_.FriendlyName -like "*$device*" -and $_.Status -eq "OK"
    }

    if ($status) {
        Write-Output "✅ Appareil '$device' détecté et connecté. Désactivation du profil HFP..."
        Start-Process $btcom -ArgumentList @("-n", "`"$device`"", "-r", "-s111e") -NoNewWindow -Wait
    } else {
        Write-Output "ℹ️ Appareil '$device' non connecté. Rien à faire."
    }
}
```

👉 Modifier la section **CONFIGURATION** pour lister les noms exacts de vos casques.

---

## 🚀 Automatisation avec le Planificateur de tâches (Option B)

1. **Ouvrir l’Observateur d’événements**

   - `Win + R` → taper `eventvwr.msc`
   - Aller dans :
     `Applications and Services Logs → Microsoft → Windows → Bluetooth-BthMini → Opérations`

2. **Identifier l’événement de connexion**

3. **Connecte ton casque**

   - Observe quel Event ID apparaît exactement quand le casque se connecte
     - Pour beaucoup de casques, c’est souvent **ID 22** ou **ID 21**
     - Note bien l’ID et la description → ce sera ton déclencheur dans le Planificateur de tâches

4. **Créer une tâche planifiée**

   - Ouvrir **Planificateur de tâches** (`taskschd.msc`)
   - _Créer une tâche_ (pas une tâche de base)

   **Onglet Déclencheurs (Triggers)**

   - Nouveau → Débuter la tâche : _Sur un événement_
   - Journal : `Microsoft-Windows-Bluetooth/Bluetooth-BthMini`
   - Source : `Bluetooth` (ou le nom exact affiché dans la colonne Source)
   - ID de l’événement : celui que tu observes à la connexion du casque

   **Onglet Actions**

   - Nouvelle action → _Démarrer un programme_
   - Programme : `powershell.exe`
   - Arguments :

     ```bash
     -ExecutionPolicy Bypass -File "C:\Scripts\Disable-HFP.ps1"
     ```

   **Onglet Conditions**

   - Décocher _Ne démarrer la tâche que si l’ordinateur est sur le secteur_ (si PC portable).

   **Onglet Général**

   - Cocher _Exécuter avec les autorisations maximales_.

5. **Tester**

   - Éteindre / rallumer le casque Bluetooth
   - Vérifier dans le terminal ou les logs du Planificateur que la tâche s’exécute
   - Le profil **Hands-Free Telephony** doit disparaître automatiquement.

---

## 📌 Notes

- Vous pouvez ajouter plusieurs casques dans `$targetDevices`.
- Pour réactiver manuellement le HFP :

  ```powershell
  btcom -n "NomDuCasque" -a -s111e
  ```

- En cas de souci, tester d’abord le script manuellement avant de l’automatiser.

---

<a id="en"></a>

# Auto-Disable Bluetooth Hands-Free Telephony on Windows

## 🎯 Purpose

Some Bluetooth headsets appear in Windows with two audio profiles:

- **A2DP (Stereo)** → good quality audio
- **HFP/HSP (Hands-Free Telephony)** → microphone enabled but poor audio quality

By default, Windows may automatically switch to the "Hands-Free Telephony" profile when the headset connects, which breaks sound quality.  
This script automates disabling the HFP service **each time the headset connects**.

---

## ⚙️ Requirements

- **PowerShell** (included with Windows 10/11)
- **Bluetooth Command Line Tools** installed and available in your `PATH`  
  👉 [Bluetooth Command Line Tools](https://bluetoothinstaller.com/bluetooth-command-line-tools)

---

## 📜 PowerShell Script

Create a file named `Disable-HFP.ps1` with the following content:

```powershell
# === CONFIGURATION ===
$targetDevices = @(
    "JBL TUNE760NC",
    "CMF Buds"
)

# btcom command name (adapt if full path is needed, e.g.: C:\BluetoothTools\btcom.exe)
$btcom = "btcom"

foreach ($device in $targetDevices) {
    # Check if the Bluetooth device is present and connected
    $status = Get-PnpDevice | Where-Object {
        $_.FriendlyName -like "*$device*" -and $_.Status -eq "OK"
    }

    if ($status) {
        Write-Output "✅ Device '$device' detected and connected. Disabling HFP profile..."
        Start-Process $btcom -ArgumentList @("-n", "`"$device`"", "-r", "-s111e") -NoNewWindow -Wait
    } else {
        Write-Output "ℹ️ Device '$device' not connected. Nothing to do."
    }
}
```

👉 Edit the **CONFIGURATION** section to list the exact names of your headsets.

---

## 🚀 Automation with Task Scheduler (Option B)

1. **Open Event Viewer**

   - `Win + R` → type `eventvwr.msc`
   - Go to:
     `Applications and Services Logs → Microsoft → Windows → Bluetooth-BthMini → Operations`

2. **Identify the connection event**

3. **Connect your headset**

   - Observe which Event ID appears exactly when the headset connects
     - For many headsets, it's often **ID 22** or **ID 21**
     - Note the ID and description → this will be your trigger in Task Scheduler

4. **Create a scheduled task**

   - Open **Task Scheduler** (`taskschd.msc`)
   - _Create a task_ (not a basic task)

   **Triggers Tab**

   - New → Begin the task: _On an event_
   - Log: `Microsoft-Windows-Bluetooth/Bluetooth-BthMini`
   - Source: `Bluetooth` (or the exact name shown in the Source column)
   - Event ID: the one you observed when connecting the headset

   **Actions Tab**

   - New action → _Start a program_
   - Program: `powershell.exe`
   - Arguments:

     ```bash
     -ExecutionPolicy Bypass -File "C:\Scripts\Disable-HFP.ps1"
     ```

   **Conditions Tab**

   - Uncheck _Start the task only if the computer is on AC power_ (for laptops).

   **General Tab**

   - Check _Run with highest privileges_.

5. **Test**

   - Turn your Bluetooth headset off/on
   - Check in the terminal or Task Scheduler logs that the task runs
   - The **Hands-Free Telephony** profile should disappear automatically.

---

## 📌 Notes

- You can add multiple headsets in `$targetDevices`.
- To manually re-enable HFP:

  ```powershell
  btcom -n "HeadsetName" -a -s111e
  ```

- If you have issues, test the script manually before automating it.
