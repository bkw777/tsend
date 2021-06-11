# tsend
Powershell implementation of the bootstrap function in [dlplus](https://github.com/bkw777/dlplus) and [mComm](http://www.club100.org/memfiles/index.php?&direction=0&order=&directory=Kurt%20McCullum)

dplus only runs on linux or osx or any other unix-like OS,  
the bootstrapper in mComm for Windows doesn't seem to work in current Windows versions,  
and the File-> Send file... option in TeraTerm doesn't work either.

So, this provides another option to bootstrap BASIC loaders into TRS-80 Model 100-alikes reliably from Windows.

This writes a specified file out on a specified serial port, one byte at a time with a 6ms pause after each byte sent, followed by a trailing 0x1A (Ctrl-Z) at the end of the file. It's meant to be fed into a `RUN "COM:..."` or `LOAD "COM:..."` command in BASIC on the portable.

Typical uses (files that you need to send this way):
* [TPDD clients](https://github.com/bkw777/dlplus/tree/master/clients)
* [REX* setup files](http://bitchin100.com/wiki/index.php?title=REX)

## Usage
Download tsend.ps1 and one of the files above, for instance TS-DOS.100.

Open a powershell window and cd to the directory where you downloaded the files.

Tell Windows to allow the script to run by running these command in the powershell window.  
You only need to do these one time the first time after you download the file, not every time you want to run it after that.
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
unblock-file -path .\tsend.ps1  
```

Finally run the script.  
    `.\tsend.ps1 -file TS-DOS.100`  

If there is more than one serial port, it will display a list of all serial ports and you will need to re-run with "-port COM#" added to the command line. Example:  
    `.\tsend.ps1 -port COM6 -file TS-DOS.100`  
    
Now you can use [LaddieAlpha](http://bitchin100.com/wiki/index.php?title=LaddieCon#LaddieAlpha) to share files with the portable.

Keywords: TRS-80 TANDY Model 100 102 200 Kyotronic KC-85 NEC PC-8201 PC-8300 Olivetti M-10 TEENY TS-DOS DKSMGR TPDD LaddieCon LaddieAlpha mComm dlplus
