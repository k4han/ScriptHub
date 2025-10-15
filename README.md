# 🚀 ScriptHub - Community Installation Scripts

> A curated collection of automated installation and configuration scripts for Linux and Windows systems, contributed by the community.

[![GitHub](https://img.shields.io/badge/GitHub-k4han%2FScriptHub-blue?logo=github)](https://github.com/k4han/ScriptHub)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [About](#about)
- [Available Scripts](#scripts)
- [Usage](#usage)
  - [Linux/macOS (.sh)](#linux-macos)
  - [Windows (.bat)](#windows)
- [Web Interface](#web-interface)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 About {#about}

**Script Hub** is an open-source project providing automated installation scripts for popular tools and services. The goal is to simplify development environment and system setup.

### Features

- ✅ **Cross-platform**: Supports both Linux (.sh) and Windows (.bat) scripts
- 🔍 **Reviewable**: All scripts are publicly available on GitHub
- 🎨 **Web UI**: Easy search and copy commands via web interface
- 📦 **Community-driven**: Everyone can contribute

---

## 📚 Available Scripts {#scripts}

View the complete list of scripts with search and filtering features at:

**🌐 [https://k4han.github.io/ScriptHub/](https://k4han.github.io/ScriptHub/)**

> The web interface provides:
> - 🔍 Search scripts by name, description, tags
> - 📋 One-click command copy
> - 👁️ View source code directly
> - 💾 Download scripts

---

## 🚀 Usage {#usage}

### Linux/macOS (.sh) {#linux-macos}

#### Method 1: Direct Execution (One-liner)

```bash
# Replace <script-name>.sh with the script you want to run
curl -fsSL https://raw.githubusercontent.com/k4han/ScriptHub/main/<script-name>.sh | sudo bash
```

**Examples:**

```bash
# Setup zRAM
curl -fsSL https://raw.githubusercontent.com/k4han/ScriptHub/main/setup-zram.sh | sudo bash

# Setup swap file
curl -fsSL https://raw.githubusercontent.com/k4han/ScriptHub/main/setup-swapfile.sh | sudo bash
```

#### Method 2: Download and Review First (Recommended)

```bash
# 1. Download the script
curl -fsSL https://raw.githubusercontent.com/k4han/ScriptHub/main/setup-zram.sh -o setup-zram.sh

# 2. Review the content
cat setup-zram.sh
# or
less setup-zram.sh

# 3. Make it executable
chmod +x setup-zram.sh

# 4. Run the script
sudo ./setup-zram.sh
```

### Windows (.bat) {#windows}

#### Method 1: Direct Execution from PowerShell

```powershell
# Download and run (requires Administrator privileges)
irm https://raw.githubusercontent.com/k4han/ScriptHub/main/<script-name>.bat | iex
```

#### Method 2: Download and Run (Recommended)

```powershell
# 1. Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/k4han/ScriptHub/main/<script-name>.bat" -OutFile "script.bat"

# 2. Review the content
Get-Content script.bat

# 3. Run as Administrator
# Right-click script.bat → Run as Administrator
```

---

## 🌐 Web Interface {#web-interface}

**🌐 Visit at: [https://k4han.github.io/ScriptHub/](https://k4han.github.io/ScriptHub/)**

The project includes a web interface for easy script discovery, filtering, and command copying.

### Interface Features

- 🔍 **Search**: Find scripts by name, description, or tags
- 🏷️ **Filter by tags**: performance, development, docker, etc.
- 🖥️ **Filter by platform**: Linux/macOS or Windows
- 📋 **Quick copy**: Integrated "Copy Command" button
- 👁️ **View source**: Direct link to GitHub for code review
- 💾 **Download**: Download scripts before running

### Run Locally (Optional)

```bash
# Clone repository
git clone https://github.com/k4han/ScriptHub.git
cd ScriptHub

# Serve with Python
python -m http.server 8000

# Or with Node.js
npx http-server -p 8000

# Open browser
# http://localhost:8000
```

---

## 🔒 Security {#security}

### ⚠️ Critical Warning

**ALWAYS review the source code before running scripts with sudo/Administrator privileges!**

### Security Recommendations

1. ✅ **Review before running**
   - Read the entire script content
   - Understand what the script does
   - Check for malicious code

2. ✅ **Download and verify**
   - Don't pipe directly to bash without reviewing
   - Download, read carefully, then run

3. ✅ **Use trusted sources only**
   - Only run scripts from official repositories
   - Verify URL and author

4. ✅ **Backup first**
   - Backup important data before running system scripts
   - Have a rollback plan

### Report Vulnerabilities

If you find a security vulnerability, please report via:

- GitHub Issues: [Report Issue](https://github.com/k4han/ScriptHub/issues)
- GitHub Security Advisory: [Create Advisory](https://github.com/k4han/ScriptHub/security/advisories/new)

---

## 🤝 Contributing {#contributing}

We welcome contributions from the community!

### How to Contribute New Scripts

1. **Fork this repository**
2. **Create your script**:
   - Use clear names (e.g., `setup-docker.sh`, `install-nodejs.bat`)
   - Add explanatory comments
   - Test thoroughly before committing
3. **Update `scripts.json`**:

```json
{
  "name": "Script Name",
  "description": "Brief description of the script",
  "file": "script-name.sh",
  "author": "Your Name",
  "updated": "2025-10-15",
  "tags": ["tag1", "tag2", "tag3"]
}
```

4. **Create a Pull Request** with detailed description
5. **Wait for review** from maintainers

### Script Guidelines

#### For Linux/macOS (.sh)

```bash
#!/bin/bash
# ============================================
# Script Name - Brief description
# Author: Your Name
# Last Updated: 2025-10-15
# ============================================

set -e  # Exit on error

# Color codes
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Logging functions
log() {
    echo -e "${GREEN}[+]${RESET} $1"
}

error() {
    echo -e "${RED}[x]${RESET} $1" >&2
}

# Main script logic
main() {
    log "Starting script..."
    # Your code here
}

main "$@"
```

#### For Windows (.bat)

```batch
@echo off
REM ============================================
REM Script Name - Brief description
REM Author: Your Name
REM Last Updated: 2025-10-15
REM ============================================

setlocal EnableDelayedExpansion

echo [+] Starting script...

REM Your code here

echo [+] Script completed successfully!
pause
```

### Pull Request Checklist

- [ ] Script tested on target operating system
- [ ] Code has adequate comments
- [ ] Updated `scripts.json` with complete metadata
- [ ] Follows project coding style
- [ ] No hardcoded credentials or sensitive data
- [ ] Proper error handling

---

## 📄 License {#license}

This project is released under the **MIT License**. See the [LICENSE](LICENSE) file for details.

### Disclaimer

```
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

**Use scripts at your own risk. Authors are not responsible for any damages.**

---

## 📞 Contact

- **GitHub**: [@k4han](https://github.com/k4han)
- **Repository**: [k4han/ScriptHub](https://github.com/k4han/ScriptHub)
- **Issues**: [Report Issues](https://github.com/k4han/ScriptHub/issues)

---

## 🌟 Support the Project

If you find this useful, give the project a ⭐ on GitHub!

[![Star History](https://img.shields.io/github/stars/k4han/ScriptHub?style=social)](https://github.com/k4han/ScriptHub/stargazers)
