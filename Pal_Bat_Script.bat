@echo off
title Pal-Bat-Script
setlocal EnableDelayedExpansion

rem 设置启动路径
set StartPath="%此处填写pal服务端启动路径%"

rem 启动参数
set StartOption=%填写启动参数%

rem 设置备份目录和源文件夹
set BackupFolder="%此处填写备份文件夹路径%"
set SourceFolder="%此处填写需要备份文件夹路径%"

rem 设置最大备份文件数（只保留最新的x个，其余的删除）
set /a MaxBackupCount=%填写需要保留的最大个数%

rem 设置要检查的程序名称和内存阈值
set "program_name=%设置为pal服务端进程名字.exe%"

rem 内存阈值，单位为 KB，例如 100000KB (约合 100MB)
set "memory_threshold=%修改为需要的内存阈值%"

rem 设置备份间隔
set WaitTime=%时间%


rem ===========================以上路径及参数设置=============================

:backuploop
rem ===========================格式化日期=====================================
set yyyy=%DATE:~0,4%
set mm=%DATE:~5,2%
set dd=%DATE:~8,2%
set hh=%TIME:~0,2%
set mi=%TIME:~3,2%
set ss=%TIME:~6,2%
set timestamp=%yyyy%%mm%%dd%_%hh%%mi%%ss%
echo %timestamp%

rem ===========================robocopy 进行备份==============================
robocopy "%SourceFolder%" "%BackupFolder%\%timestamp%" /e /COPYALL /TEE /LOG+:"backup.log" /R:5 /W:5

rem ===========================robocopy 进行备份==============================
set "count=0"
for /d %%D in ("%BackupFolder%\*") do set /a "count+=1"
rem 如果备份数量超过最大备份次数，则删除最旧的备份文件夹
if !count! gtr %MaxBackupCount% (
    for /f "skip=%MaxBackupCount% tokens=*" %%F in ('dir /b /a:d /o:-d "%BackupFolder%"') do (
        rd /s /q "%BackupFolder%\%%F"
        goto :breakbackup
    )
)
:breakbackup


rem 获取指定程序的内存使用情况
for /f "tokens=5" %%a in ('tasklist /fi "imagename eq %program_name%" ^| find /i "%program_name%"') do (
    set "memory=%%a"
    set "memory=!memory:,=!"
    set /a "memoryInKB=memory"
)

rem 检查内存使用是否超过阈值
if !memoryInKB! gtr %memory_threshold% (
    echo Memory usage of %program_name% exceeds threshold.

    rem 结束指定程序
    taskkill /f /im %program_name%
    rem 重新启动指定程序
    echo Restarting %program_name%...
    start "" %StartPath% %StartOption%
) else (
    echo Memory usage of %program_name% is within the threshold.
)


rem 等待x分钟
timeout /t %WaitTime% /nobreak
goto backuploop



