Get-ChildItem -Path . -Recurse -Directory |
Where-Object { $_.Name -in @('venv', '.venv', 'env', '.env', '__pycache__', 'node_modules') } |
Remove-Item -Recurse -Force
