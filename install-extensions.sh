#!/usr/bin/env bash

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt
fi

# Create .vscode directory and settings.json
mkdir -p .vscode
cat << 'EOF' > .vscode/settings.json
{
    "python.testing.unittestArgs": ["-v", "-s", "./src/test", "-p", "*test*.py"],
    "python.testing.pytestEnabled": false,
    "python.testing.unittestEnabled": true,
    "extensions.ignoreRecommendations": true,
    "python.envFile": "${workspaceFolder}/.env"
}
EOF

# Create post-commit git hook
mkdir -p .git/hooks
cat << 'EOF' > .git/hooks/post-commit
#!/bin/bash
git push
git log -1 --shortstat > history_log.txt
EOF
chmod +x .git/hooks/post-commit

# Generate .env file with PYTHONPATH
echo "PYTHONPATH=." > .env

# Install VS Code extension if 'code' command is available
if command -v code >/dev/null 2>&1; then
    code --install-extension revaturePro.revature-python-labs

    if [ -f "src/main/lab.py" ]; then
        code -r src/main/lab.py
    elif [ -f "src/main/app.py" ]; then
        code -r src/main/app.py
    else
        find src/main -type f -name "*.py" | while read -r file; do
            code -r "$file"
        done
    fi
else
    echo "VS Code 'code' command not found. Skipping extension install and file opening."
fi
