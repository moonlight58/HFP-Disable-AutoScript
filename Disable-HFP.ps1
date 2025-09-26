# === CONFIG ===
$targetDevices = @(
    "JBL TUNE760NC",
    "CMF Buds"
)

# Path to btcom (assumes it's in PATH, otherwise full path like C:\BluetoothTools\btcom.exe)
$btcom = "btcom"

foreach ($device in $targetDevices) {
    # Check if the Bluetooth device is present and connected
    $status = Get-PnpDevice | Where-Object {
        $_.FriendlyName -like "*$device*" -and $_.Status -eq "OK"
    }

    if ($status) {
        Write-Output "Device '$device' is connected. Disabling HFP..."
        Start-Process $btcom -ArgumentList @("-n", "`"$device`"", "-r", "-s111e") -NoNewWindow -Wait
    } else {
        Write-Output "Device '$device' not connected. Nothing to do."
    }
}
