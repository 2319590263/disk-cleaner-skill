@echo off
echo 正在优化OpenClaw启动配置...

REM 停止当前服务
openclaw gateway stop

REM 等待2秒确保完全停止
timeout /t 2 /nobreak >nul

REM 清理临时文件
if exist "%TEMP%\openclaw\*" (
    echo 清理临时文件...
    del /q "%TEMP%\openclaw\*"
)

REM 启动优化后的服务
echo 启动优化后的OpenClaw...
openclaw gateway start

echo 优化完成！