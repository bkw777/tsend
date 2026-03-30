# tsend.ps1
# Powershell implementation of a bootstrapper for "Model T" computers.
# b.kenyon.w@gmail.com
#
# Reads a local file and writes it out to a serial port.
# Appends a trailing Ctrl-Z if the file doesn't already include one.
# The script both sets the pc serial port to 9600,8n1 with xon/xoff flow control,
# and shows you what to type in BASIC so that the portable does the same.
#
# Usage (example):
# .\tsend.ps1 -file TS-DOS.100
# .\tsend.ps1 -port COM5 -file TS-DOS.100
# .\tsend.ps1 -port COM5 -baud 600 -file TS-DOS.100
#
# -port is optional. If there is only one serial port present, it will be used automatically.
# If there are multiple serial ports present, they are displayed so you can re-run with -port.
#
# -baud is optional. Default is 9600. Values: 19200 9600 4800 2400 1200 600 300
# The COM: stat string in the BASIC prompt will reflect the actual baud rate.
#

param (
	[string]$port,
	[int]$baud = 9600,
	[string]$file
)

$char_delay_ms = 0
$basic_eof = [char][byte]0x1A
$s = @{19200=9;9600=8;4800=7;2400=6;1200=5;600=4;300=3}
$c = $s[$baud]

function cleanup {
	if ($p.IsOpen) {
		#Write-Host "closing $($p.PortName)"
		$p.DiscardInBuffer()
		$p.DiscardOutBuffer()
		$p.close()
	}
}

#trap {cleanup;exit}

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
		exit 1
	}
	$port = $ports[0]
}

if($file -eq ""){
	Write-Host "Specify -file filename"
	exit 1
}

$payload = Get-Content -Path $file -Raw
if ($payload[-1] -ne $basic_eof) { $payload += [char][byte]$basic_eof }

$p = new-Object System.IO.Ports.SerialPort $port,$baud,None,8,one

$p.handshake = "XOnXOff"
#$p.WriteBufferSize = 128
#$p.Encoding = [System.Text.Encoding]::GetEncoding(437)
$p.Encoding = [System.Text.Encoding]::GetEncoding(1252)
#$p.Encoding = [System.Text.Encoding]::GetEncoding("utf-8")
#$p.ReadTimeout = 5000
#$p.WriteTimeout = 5000

#$p

#Write-Host "Opening $($p.PortName)"
try {$p.open()}
catch {
	Write-Host "Failed to open $($p.PortName)"
	cleanup
	exit 1
}
$p.DiscardInBuffer()
$p.DiscardOutBuffer()

#$p

Write-Host ""
Write-Host "Prepare the portable to receive."
Write-Host "Type one of the following into BASIC and press Enter:"
Write-Host ""
Write-Host "    RUN `"COM:$($c)8N1ENN`"     (TANDY/Olivetti/Kyotronic)"
Write-Host "    RUN `"COM:$($c)N81XN`"      (NEC)"
Write-Host ""
Read-Host "Press Enter here after the portable is ready"
Write-Host "Sending..."

$fancy = $true
if ($fancy) {
	$l = $payload.length
	$self = $MyInvocation.InvocationName
	for ($i=0 ; $i -lt $l ; $i++) {
		$pc = [math]::round($i/$l*100)
		Write-Progress -Activity "$self" -Status "Sending $file on $port    $i/$l bytes" -PercentComplete $pc
		$p.write($payload,$i,1)
		if ($char_delay_ms) { Start-Sleep -milliseconds $char_delay_ms }
	}
} else {
	$p.write($payload)
}

Write-Host "Done"
cleanup
