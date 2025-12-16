#!/bin/bash

# Setup script for RAG Local Project

echo "Setting up Local RAG System..."

# Backend setup
echo ""
echo "Setting up backend..."
cd backend

if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

echo "Installing Python dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo "Backend setup complete"

# Frontend setup
cd ../frontend
echo ""
echo "Setting up frontend..."

if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
fi

echo "Frontend setup complete"

# Ollama check
cd ..
echo ""
echo "Checking Ollama installation..."
if command -v ollama &> /dev/null; then
    echo "Ollama is installed"
    echo ""
    echo "Checking for llama3.2 model..."
    if ollama list | grep -q llama3.2; then
        echo "llama3.2 model is available"
    else
        echo "llama3.2 model not found"
        echo "Run: ollama pull llama3.2"
    fi
else
    echo "Ollama is not installed"
    echo "Install with: brew install ollama"
fi

echo ""
echo "Setup complete!"
echo ""
echo "To start the application:"
echo ""
echo "1. Start backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   python -m app.main"
echo ""
echo "2. Start Ollama (in another terminal):"
echo "   ollama serve"
echo ""
echo "3. Start frontend (in another terminal):"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "4. Open browser: http://localhost:5173"