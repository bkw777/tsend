# tsend.ps1
# Powershell implementation of a bootstrapper for "Model T Computers"
#
# Reads a local file and writes it out to a serial port, one byte at a time
# with a 6ms pause after each byte, and sends a trailing Ctrl-Z at the end.
#
# Usage (example):
# .\tsend.ps1 -port COM5 -file TS-DOS.100
#
# If port is omitted, and there is only one serial port detected, it is used
# If port is omitted, and there are more than one serial ports detected, the detected ports are displayed and the user is prompted to select one.
# If file is omitted, the user is prompted to supply a flename.

param (
	[string]$port,
	[string]$file
)
$char_delay_ms = 6

# Serial port
if($port -eq ""){
	[string[]]$ports = [System.IO.Ports.SerialPort]::getportnames()
	if($ports.count -lt 1) {
		Write-Host "No serial ports detected."
		exit
	}
	if($ports.count -gt 1) {
		Write-Host "Multiple serial ports detected."
		Write-Host "Specify -port COM#"
		#Write-Host "Detected serial ports:"
		$portList = get-pnpdevice -class Ports -ea 0
		foreach($device in $portList) {
			if ($device.Present) {
				Write-Host $device.Name "(Manufacturer:"$device.Manufacturer")"
			}
		}
		exit
	}
	$port = $ports[0]
}

if($file -eq ""){
	Write-Host "Specify -file filename"
	exit
}	

Write-Host ""
Write-Host "Prepare the portable to receive. Hints:"
Write-Host "	RUN `"COM:98N1ENN`"		# for TRS-80, TANDY, Kyotronic, Olivetti"
Write-Host "	RUN `"COM:9N81XN`"		# for NEC"
Write-Host ""
Read-Host "Press Enter when the portable is ready..."

[byte[]] $bytes = Get-Content $file -encoding byte -readcount 0
$p = new-Object System.IO.Ports.SerialPort $port,19200,None,8,one
$p.open()

foreach ($byte in $bytes) {
	$p.Write($byte,0,1)
	Write-Host "." -nonewline
	Start-Sleep -milliseconds $char_delay_ms
}

$p.Write([byte[]]0x1A,0,1)
Write-Host ""

$p.Close()
