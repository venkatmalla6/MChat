import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import Home from './Home';
import Chat from './Chat';
import Features from './Features';
import About from './About';
import Profile from './Profile';
import { auth } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';
import './App.css';

/**
 * Guards a route so only authenticated Firebase users can access it.
 * Shows a loading screen while Firebase is initialising.
 */
const ProtectedRoute = ({ children }) => {
  const [status, setStatus] = useState('checking'); // 'checking' | 'ok' | 'fail'

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (user) => {
      setStatus(user ? 'ok' : 'fail');
    });
    return () => unsub();
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

/** Redirect to /home if the user is already signed in. */
const AuthRoute = ({ children }) => {
  const [status, setStatus] = useState('checking');

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (user) => {
      setStatus(user ? 'ok' : 'fail');
    });
    return () => unsub();
  }, []);

  if (status === 'checking') {
    return (
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        height: '100vh', background: '#0f172a', color: '#94a3b8', fontSize: '1rem'
      }}>
        Loading…
      </div>
    );
  }

  return status === 'ok' ? <Navigate to="/home" replace /> : children;
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
