set -euo pipefail

python -m venv .venv
if [ -f ".venv/Scripts/activate" ]; then
    source .venv/Scripts/activate
else
    source .venv/bin/activate
fi
pip install -r requirements.txt
python test_environment.py
echo "Setup complete."