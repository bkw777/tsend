# tsend
Powershell implementation of the bootstrap function in [dlplus](https//github.com/bkw777/dlplus) and [mComm](http://www.club100.org/memfiles/index.php?&direction=0&order=&directory=Kurt%20McCullum)

Usage:  
    `.\tsend.ps1 -file TS-DOS.100`  
Or  
    `.\tsend.ps1 -port COM6 -file TS-DOS.100`  

"-port COMx" can be omitted if there is only one serial port present.

Writes the specified file out on the specified serial port, one byte at a time with a 6ms pause after each byte sent, followed by a single trailing 0x1A (Ctrl-Z) at the end of the file.

Typical uses (files that you need to send this way):
* [TPDD clients](https://github.com/bkw777/dlplus/tree/master/clients)
* [REX* setup files](http://bitchin100.com/wiki/index.php?title=REX)

If you can't execute the script, try setting your users's execution policy, and unblocking the script:  
    `PS> unblock-file -path .\tsend.ps1`  
    `PS> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`  
    
This was intended to be a simple option to provide a bootstrapper to use with [LaddieAlpha](http://bitchin100.com/wiki/index.php?title=LaddieCon#LaddieAlpha), since it does not come with a bootstrapper itself. But in the end, with the powershell security complexity, this is not any simpler to use than just installing TeraTerm and using it's File Send function, or installing mComm for Windows and using it's bootstrapper.

Keywords: TRS-80 TANDY Model 100 102 200 Kyotronic KC-85 NEC PC-8201 PC-8300 Olivetti M-10 TEENY TS-DOS DKSMGR TPDD LaddieCon LaddieAlpha mComm dlplus
