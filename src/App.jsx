import { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import Home from './Home';
import Chat from './Chat';
import Features from './Features';
import About from './About';
import Profile from './Profile';
import { auth, db } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';
import { collection, query, where, onSnapshot } from 'firebase/firestore';
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

/** Global Notification Listener for incoming messages */
const NotificationHandler = () => {
  useEffect(() => {
    let unsub = () => {};
    // Record the time this component mounts to avoid notifying for old messages
    const mountTime = Date.now() / 1000;

    const unsubAuth = onAuthStateChanged(auth, (user) => {
      if (user) {
        if ('Notification' in window && Notification.permission === 'default') {
          Notification.requestPermission();
        }

        const q = query(
          collection(db, 'messages'),
          where('participants', 'array-contains', user.uid)
        );

        unsub = onSnapshot(q, (snap) => {
          snap.docChanges().forEach(change => {
            if (change.type === 'added') {
              const data = change.doc.data();
              const msgTime = data.created_at?.seconds || 0;
              // Only alert if the message was created after we mounted, and it's not sent by us
              if (msgTime > mountTime && data.sender_uid !== user.uid) {
                if ('Notification' in window && Notification.permission === 'granted') {
                  new Notification(`New message from ${data.sender_name}`, {
                    body: data.content
                  });
                }
              }
            }
          });
        });
      } else {
        unsub();
      }
    });

    return () => {
      unsubAuth();
      unsub();
    };
  }, []);

  return null;
};

function App() {
  return (
    <Router>
      <NotificationHandler />
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
