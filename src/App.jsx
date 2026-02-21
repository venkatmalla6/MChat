import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import Home from './Home';
import Chat from './Chat';
import Features from './Features';
import About from './About';
import Profile from './Profile';
import { getToken, clearToken } from './auth';
import './App.css';

// Validates token with the server; clears storage if invalid/expired
const ProtectedRoute = ({ children }) => {
  const [status, setStatus] = useState('checking'); // 'checking' | 'ok' | 'fail'

  useEffect(() => {
    const token = getToken();
    if (!token) {
      setStatus('fail');
      return;
    }

    fetch('/api/user', {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then((res) => {
        if (res.ok) {
          setStatus('ok');
        } else {
          clearToken();
          setStatus('fail');
        }
      })
      .catch(() => {
        // Network/server unreachable — clear session
        clearToken();
        setStatus('fail');
      });
  }, []);

  if (status === 'checking') {
    return (
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        height: '100vh', background: '#0f172a', color: '#94a3b8', fontSize: '1rem'
      }}>
        Verifying session…
      </div>
    );
  }

  return status === 'ok' ? children : <Navigate to="/login" replace />;
};

// Redirect to /home if already logged in
const AuthRoute = ({ children }) => {
  const token = getToken();
  return token ? <Navigate to="/home" replace /> : children;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="/login" element={<AuthRoute><Login /></AuthRoute>} />
        <Route path="/home" element={<ProtectedRoute><Home /></ProtectedRoute>} />
        <Route path="/features" element={<Features />} />
        <Route path="/about" element={<About />} />
        <Route path="/chat" element={<ProtectedRoute><Chat /></ProtectedRoute>} />
        <Route path="/profile" element={<ProtectedRoute><Profile /></ProtectedRoute>} />
      </Routes>
    </Router>
  );
}

export default App;
