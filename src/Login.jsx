import React, { useState } from 'react';
import { Mail, Lock, Eye, EyeOff, MessageSquare, User, Cloud } from 'lucide-react';
import { useNavigate, Link } from 'react-router-dom';
import { auth, db } from './firebase';
import {
    createUserWithEmailAndPassword,
    signInWithEmailAndPassword,
    sendPasswordResetEmail,
    updateProfile,
} from 'firebase/auth';
import { doc, setDoc, serverTimestamp, collection, query, where, getDocs, limit } from 'firebase/firestore';
import { applyPersistence } from './auth';
import mchatLogo from './assets/mchat.png';
import './Login.css';

/** Generate a random 6-character alphanumeric Chat ID */
const genChatId = () => Math.random().toString(36).substr(2, 6).toUpperCase();

const Login = () => {
    const [showPassword, setShowPassword] = useState(false);
    const [email, setEmail] = useState('');
    const [name, setName] = useState('');
    const [password, setPassword] = useState('');
    const [isRegistering, setIsRegistering] = useState(false);
    const [rememberMe, setRememberMe] = useState(false);
    const [error, setError] = useState('');
    const [successMsg, setSuccessMsg] = useState('');
    const [loading, setLoading] = useState(false);

    // Forgot password
    const [forgotStep, setForgotStep] = useState('idle'); // 'idle' | 'sending'
    const navigate = useNavigate();

    const clearMessages = () => { setError(''); setSuccessMsg(''); };

    // ── Register ────────────────────────────────────────────────────────────
    const handleRegister = async () => {
        await applyPersistence(rememberMe);
        const cred = await createUserWithEmailAndPassword(auth, email, password);
        const displayName = name || email.split('@')[0];
        await updateProfile(cred.user, { displayName });

        const chatId = genChatId();
        await setDoc(doc(db, 'users', cred.user.uid), {
            email,
            name: displayName,
            chat_id: chatId,
            avatar_url: null,
            created_at: serverTimestamp(),
        });

        setSuccessMsg('Registration successful! Please sign in.');
        setIsRegistering(false);
        setEmail(''); setPassword(''); setName('');
    };

    // ── Login ───────────────────────────────────────────────────────────────
    const handleLogin = async () => {
        await applyPersistence(rememberMe);
        let loginEmail = email.trim();

        // If the user entered a Chat ID (no @ symbol)
        if (!loginEmail.includes('@')) {
            try {
                const q = query(
                    collection(db, 'users'),
                    where('chat_id', '==', loginEmail.toUpperCase()),
                    limit(1)
                );
                const snap = await getDocs(q);
                if (!snap.empty) {
                    loginEmail = snap.docs[0].data().email;
                } else {
                    throw new Error('auth/user-not-found');
                }
            } catch (err) {
                if (err.message === 'auth/user-not-found') throw err;
                throw new Error("Unable to verify Chat ID. Please log in using your Email Address.");
            }
        }

        await signInWithEmailAndPassword(auth, loginEmail, password);
        navigate('/home');
    };

    // ── Auth dispatcher ─────────────────────────────────────────────────────
    const handleAuth = async (e) => {
        e.preventDefault();
        clearMessages();
        setLoading(true);
        try {
            if (isRegistering) {
                await handleRegister();
            } else {
                await handleLogin();
            }
        } catch (err) {
            const msg = {
                'auth/email-already-in-use': 'This email is already registered. Please sign in instead.',
                'auth/user-not-found': 'No account found with that email.',
                'auth/wrong-password': 'Incorrect password. Please try again.',
                'auth/invalid-credential': 'Invalid email or password.',
                'auth/weak-password': 'Password must be at least 6 characters.',
                'auth/invalid-email': 'Please enter a valid email address.',
                'auth/network-request-failed': 'Network error. Check your connection.',
            }[err.code] || err.message;
            setError(msg);
        } finally {
            setLoading(false);
        }
    };

    // ── Forgot Password ─────────────────────────────────────────────────────
    const handleForgotPassword = async (e) => {
        e.preventDefault();
        clearMessages();
        setLoading(true);
        try {
            await sendPasswordResetEmail(auth, email);
            setSuccessMsg('Password reset email sent! Check your inbox.');
            setForgotStep('idle');
        } catch (err) {
            const msg = {
                'auth/user-not-found': 'No account found with that email.',
                'auth/invalid-email': 'Please enter a valid email address.',
            }[err.code] || err.message;
            setError(msg);
        } finally {
            setLoading(false);
        }
    };

    const cardTitle = forgotStep === 'idle'
        ? (isRegistering ? 'Create Account' : 'Sign In')
        : 'Reset Password';

    const cardSubtitle = forgotStep !== 'idle'
        ? 'Enter your email and we\'ll send a reset link.'
        : isRegistering ? 'Join us today!' : 'Welcome back! Please enter your details.';

    return (
        <div className="login-container">
            {/* Navbar */}
            <nav className="navbar">
                <div className="logo">
                    <div className="logo-icon" style={{ width: '40px', height: '40px', padding: 0, overflow: 'hidden' }}>
                        <img src={mchatLogo} alt="MChat" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    </div>
                    <span className="logo-text">MChat</span>
                </div>
                <div className="nav-links">
                    <Link to="/home">Home</Link>
                    <Link to="/features">Features</Link>
                    <Link to="/about">About</Link>
                    {forgotStep === 'idle' && (
                        <button className="signup-btn-nav" onClick={() => { setIsRegistering(!isRegistering); clearMessages(); }}>
                            {isRegistering ? 'Sign In' : 'Sign Up'}
                        </button>
                    )}
                </div>
            </nav>

            {/* Main Content */}
            <div className="main-content">
                {/* Left Illustration */}
                <div className="illustration-left">
                    <div className="cloud cloud-1"></div>
                    <div className="cloud cloud-2"></div>
                    <div className="man-placeholder">
                        <div className="man-head"></div>
                        <div className="man-body"></div>
                        <div className="laptop"></div>
                    </div>
                </div>

                {/* Login Card */}
                <div className="login-card">
                    <div className="card-header">
                        <div className="cloud-icon-large">
                            <Cloud size={40} fill="white" color="#4A90E2" />
                            <div className="arrow-up"></div>
                        </div>
                        <h2>{cardTitle} <span>to MChat</span></h2>
                        <p>{cardSubtitle}</p>
                    </div>

                    {/* ── Sign In / Register ── */}
                    {forgotStep === 'idle' && (
                        <form className="login-form" onSubmit={handleAuth}>
                            {error && <div className="error-message" style={{ color: '#feb2b2', fontSize: '0.9rem' }}>{error}</div>}
                            {successMsg && <div style={{ color: '#9ae6b4', fontSize: '0.9rem', marginBottom: '0.5rem' }}>{successMsg}</div>}

                            <div className="input-group">
                                <Mail className="input-icon" size={20} />
                                <input type="text" placeholder="Email or Chat ID" value={email}
                                    onChange={(e) => setEmail(e.target.value)} required />
                            </div>

                            {isRegistering && (
                                <div className="input-group">
                                    <User className="input-icon" size={20} />
                                    <input type="text" placeholder="Full Name" value={name}
                                        onChange={(e) => setName(e.target.value)} required />
                                </div>
                            )}

                            <div className="input-group">
                                <Lock className="input-icon" size={20} />
                                <input type={showPassword ? "text" : "password"} placeholder="Password"
                                    value={password} onChange={(e) => setPassword(e.target.value)} required />
                                <button type="button" className="toggle-password"
                                    onClick={() => setShowPassword(!showPassword)}>
                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>

                            {!isRegistering && (
                                <div className="form-footer">
                                    <button type="button"
                                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#63b3ed', fontSize: '0.85rem', padding: 0 }}
                                        onClick={() => { setForgotStep('sending'); clearMessages(); }}>
                                        Forgot password?
                                    </button>
                                    <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#a0aec0', fontSize: '0.85rem', userSelect: 'none' }}>
                                        <input
                                            type="checkbox"
                                            checked={rememberMe}
                                            onChange={e => setRememberMe(e.target.checked)}
                                            style={{ accentColor: '#4299e1', width: '15px', height: '15px', cursor: 'pointer' }}
                                        />
                                        Remember me
                                    </label>
                                </div>
                            )}

                            <button type="submit" className="signin-btn" disabled={loading}>
                                {loading ? 'Please wait...' : isRegistering ? 'Sign Up' : 'Sign In'}
                            </button>

                            <div className="card-footer" style={{ marginTop: '1rem' }}>
                                <p>
                                    {isRegistering ? 'Already have an account?' : "Don't have an account?"}
                                    <button className="link-btn" onClick={() => { setIsRegistering(!isRegistering); clearMessages(); }}
                                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#63b3ed', fontWeight: 600, marginLeft: '5px', fontSize: 'inherit' }}>
                                        {isRegistering ? 'Sign In' : 'Sign Up'}
                                    </button>
                                </p>
                            </div>
                        </form>
                    )}

                    {/* ── Forgot Password ── */}
                    {forgotStep === 'sending' && (
                        <form className="login-form" onSubmit={handleForgotPassword}>
                            {error && <div className="error-message" style={{ color: '#feb2b2', fontSize: '0.9rem' }}>{error}</div>}
                            {successMsg && <div style={{ color: '#9ae6b4', fontSize: '0.9rem', marginBottom: '0.5rem' }}>{successMsg}</div>}
                            <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginBottom: '1rem' }}>
                                Enter your registered email and we'll send you a password reset link.
                            </p>
                            <div className="input-group">
                                <Mail className="input-icon" size={20} />
                                <input type="email" placeholder="Your registered email" value={email}
                                    onChange={(e) => setEmail(e.target.value)} required />
                            </div>
                            <button type="submit" className="signin-btn" disabled={loading}>
                                {loading ? 'Sending...' : 'Send Reset Link'}
                            </button>
                            <button type="button" onClick={() => { setForgotStep('idle'); clearMessages(); }}
                                style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#a0aec0', fontSize: '0.85rem', marginTop: '0.5rem', width: '100%' }}>
                                ← Back to Sign In
                            </button>
                        </form>
                    )}
                </div>

                {/* Right Illustration */}
                <div className="illustration-right">
                    <div className="cloud cloud-3"></div>
                    <div className="woman-placeholder">
                        <div className="woman-head"></div>
                        <div className="woman-body"></div>
                        <div className="phone"></div>
                    </div>
                    <div className="file-icons">
                        <div className="file-icon file-1"></div>
                        <div className="file-icon file-2"></div>
                    </div>
                </div>
            </div>

            {/* Footer Features */}
            <div className="features-footer">
                <div className="feature">
                    <div className="feature-icon bolt"></div>
                    <span>Real-Time Chat</span>
                </div>
                <div className="feature">
                    <div className="feature-icon briefcase"></div>
                    <span>Easy File Sharing</span>
                </div>
                <div className="feature">
                    <div className="feature-icon shield"></div>
                    <span>Secure &amp; Reliable</span>
                </div>
            </div>

            <div className="bg-cloud-bottom"></div>
        </div>
    );
};

export default Login;
