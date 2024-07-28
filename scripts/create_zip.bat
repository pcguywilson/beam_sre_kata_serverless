@echo off
mkdir build
copy lambda_function.py build\
cd build
powershell Compress-Archive -Path * -DestinationPath ..\lambda_function.zip
cd ..
rmdir /s /q build
