cd ./tools/H5ResConvertCLI/
@echo off
chcp 65001
@REM 使用powerShell 打开
echo  此过程会将 当前目录中所有 assetbundle 资源进行转换。

.\H5ResConvertCLI.exe -r ../../ ../../

pause
