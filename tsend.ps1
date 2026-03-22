# XON/XOFF VERSION - NOT WORKING
# The script runs without error, but the xon/xoff is not actually pausing transmission,
# so the file gets corrupt in transmission and fails to load on the receiving machine.
# On linux, proper operation requires:
#   VMIN = 1
#   VTIME = 0
#   IXON & IXOFF enabled
#   IXANY NOT ENABLED
# I don't know how to do the equivalent of setting these on Windows.
# TS-DOS.100 fails to load even with the old 8ms delay,
# but works fine on linux using either dl -b or even just using simple cat after setting stty settings.
#
# tsend.ps1
# Powershell implementation of a bootstrapper for "Model T" computers.
# b.kenyon.w@gmail.com
#
# Reads a local file and writes it out to a serial port.
# Sends a trailing Ctrl-Z at the end.
# The script both sets the pc serial port to 9600,8n1 with xon/xoff flow control,
# and shows you what to type in BASIC so that the portable does the same.
#
# Usage (example):
# .\tsend.ps1 -port COM5 -file TS-DOS.100
#
# -port is optional. If there is only one serial port present, it will be used automatically.
# If there are multiple serial ports present, they are displayed so you can re-run with -port. 

param (
	[string]$port,
	[string]$file
)

$char_delay_ms = 0  # not needed with working xon/xoff, otherwise may need anywhere from 5 to 10
[byte] $basic_eof = 0x1A

if($port -eq ""){
	[string[]]$ports = [System.IO.Ports.SerialPort]::getportnames()
	if($ports.count -lt 1) {
		Write-Host "No serial ports detected."
		exit 1
	}
	if($ports.count -gt 1) {
		Write-Host "Multiple serial ports detected."
		Write-Host "Specify -port COM#"
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
	exit 1
}

Write-Host ""
Write-Host "Prepare the portable to receive. Hints:"
Write-Host "	RUN `"COM:88N1ENN`"	# for TRS-80, TANDY, Kyotronic, Olivetti"
Write-Host "	RUN `"COM:8N81XN`"	# for NEC"
Write-Host ""
Read-Host "Press Enter when the portable is ready"

$payload = Get-Content -path $file -raw
$p = new-Object System.IO.Ports.SerialPort $port,9600,None,8,one
$p.handshake = "XOnXOff"
#$p.ReadTimeout = InfiniteTimeout
#$p.WriteTimeout = InfiniteTimeout

try {$p.open()}
catch {
	Write-Host "Failed to open $port"
	exit 1
}

$size = $payload.length
$self = $MyInvocation.InvocationName
for ($i = 0; $i -lt $size ; $i++) {
	$p.write($payload,$i,1)
	$pc = [math]::round($i/$size*100)
	Write-Progress -Activity "$self" -Status "Sending $file on $port    $i/$size bytes" -PercentComplete $pc
	if ($char_delay_ms) { Start-Sleep -milliseconds $char_delay_ms }
}
$p.write($basic_eof,0,1)

$p.close()
