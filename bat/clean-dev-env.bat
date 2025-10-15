REM ============================================
REM clean development environments
REM Author: kh4n
REM Last Updated: 2025-10-15
REM ============================================
Get-ChildItem -Path . -Recurse -Directory |
Where-Object { $_.Name -in @('venv', '.venv', 'env', '.env', '__pycache__', 'node_modules') } |
Remove-Item -Recurse -Force
