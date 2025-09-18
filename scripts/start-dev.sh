#!/bin/bash
# Development startup script

echo "🚀 Starting Development Environment..."

# Set environment for development
export FLASK_ENV=development

# Backend setup
echo "📦 Setting up backend..."
cd backend
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

source venv/bin/activate || source venv/Scripts/activate  # Windows compatibility
pip install -r requirements.txt

echo "🔧 Starting Flask backend in development mode..."
python app.py &
BACKEND_PID=$!

# Frontend setup
echo "🎨 Setting up frontend..."
cd ../frontend
npm install
echo "🔧 Starting Vite dev server..."
npm run dev &
FRONTEND_PID=$!

echo "✅ Development environment started!"
echo "Backend: http://localhost:5000"
echo "Frontend: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for interrupt
trap "echo 'Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait