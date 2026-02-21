import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import Home from './Home';
import Chat from './Chat';
import Features from './Features';
import About from './About';
import Profile from './Profile';
import './App.css';

// Redirect to /login if not authenticated
const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  return token ? children : <Navigate to="/login" replace />;
};

// Redirect to /home if already logged in
const AuthRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  return token ? <Navigate to="/home" replace /> : children;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to={localStorage.getItem('token') ? '/home' : '/login'} replace />} />
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
