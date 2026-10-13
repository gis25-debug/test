@echo off
title VocaFlow 영어 학습 앱 실행기
chcp 65001 >nul
echo VocaFlow 영어 학습 앱을 시작합니다...
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
