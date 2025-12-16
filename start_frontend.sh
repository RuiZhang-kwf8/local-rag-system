#!/bin/bash

# Quick start script - runs frontend dev server

echo "Starting Frontend Development Server..."
echo ""

cd "$(dirname "$0")/frontend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies first..."
    npm install
    echo ""
fi

echo "Starting Vite dev server..."
echo "Frontend will be available at: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop"
echo ""

npm run dev
