# tsend.ps1
# Powershell implementation of a bootstrapper for "Model T" computers.
# b.kenyon.w@gmail.com
#
# Reads a local file and writes it out to a serial port, one byte at a time
# with a 6ms pause after each byte, and sends a trailing Ctrl-Z at the end.
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
$char_delay_ms = 6

# serial port
if($port -eq ""){
	# no port specified, get list of ports
	[string[]]$ports = [System.IO.Ports.SerialPort]::getportnames()
	if($ports.count -lt 1) {
		Write-Host "No serial ports detected."
		exit
	}
	if($ports.count -gt 1) {
		# multiple ports found, display a more informative list of all ports
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
	# exactly one port found, use it automatically
	$port = $ports[0]
}

# payload file
if($file -eq ""){
	Write-Host "Specify -file filename"
	exit
}

# prompt & pause to get the portable ready befor proceeding
Write-Host ""
Write-Host "Prepare the portable to receive. Hints:"
Write-Host "	RUN `"COM:98N1ENN`"	# for TRS-80, TANDY, Kyotronic, Olivetti"
Write-Host "	RUN `"COM:9N81XN`"	# for NEC"
Write-Host ""
Read-Host "Press Enter when the portable is ready"

# read the payload file
[byte[]] $bytes = Get-Content $file -encoding byte -readcount 0

# open the serial port
$p = new-Object System.IO.Ports.SerialPort $port,19200,None,8,one
try {
	$p.open()
}
catch {
	Write-Host "Failed to open $port"
	exit 1
}

# dribble the payload out the serial port
$i = 0
$size = $bytes.count
$self = $MyInvocation.InvocationName
foreach ($byte in $bytes) {
	$i++
	# write one byte
	$p.write($byte,0,1)
	# progress indicator
	# doing this every byte is slow, but we want this to go slow anyway
	$pc = [math]::round($i/$size*100)
	Write-Progress -Activity "$self" -Status "Sending $file on $port    $i/$size bytes" -PercentComplete $pc
	# sleep 6 ms
	Start-Sleep -milliseconds $char_delay_ms
}
# write the BASIC EOF
$p.write([byte[]]0x1A,0,1)

$p.close()
