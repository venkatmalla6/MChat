import React, { useState } from 'react';
import { Mail, Lock, Cloud, Eye, EyeOff, MessageSquare, User, KeyRound, ShieldCheck } from 'lucide-react';
import { useNavigate, Link } from 'react-router-dom';
import { saveToken, saveUserMeta } from './auth';
import './Login.css';

const API_URL = '/api';

const Login = () => {
    const [showPassword, setShowPassword] = useState(false);
    const [email, setEmail] = useState('');
    const [name, setName] = useState('');
    const [password, setPassword] = useState('');
    const [isRegistering, setIsRegistering] = useState(false);
    const [rememberMe, setRememberMe] = useState(false);
    const [error, setError] = useState('');
    const [successMsg, setSuccessMsg] = useState('');
    const navigate = useNavigate();

    // Forgot password: 'idle' | 'sent' | 'reset'
    const [forgotStep, setForgotStep] = useState('idle');
    const [otp, setOtp] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [loading, setLoading] = useState(false);

    const clearMessages = () => { setError(''); setSuccessMsg(''); };

    // ── Step 1: Send OTP ────────────────────────────────────────────────────
    const handleSendOTP = async (e) => {
        e.preventDefault();
        clearMessages();
        setLoading(true);
        try {
            const res = await fetch(`${API_URL}/forgot-password`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email }),
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'Failed to send OTP');
            setSuccessMsg('OTP sent! Check your email inbox.');
            setForgotStep('sent');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    // ── Step 2: Verify OTP + Reset Password ────────────────────────────────
    const handleVerifyOTP = async (e) => {
        e.preventDefault();
        clearMessages();
        setLoading(true);
        try {
            const res = await fetch(`${API_URL}/verify-otp`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, otp, newPassword }),
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'Verification failed');
            setSuccessMsg('Password reset successful! You can now sign in.');
            setForgotStep('idle');
            setIsRegistering(false);
            setEmail('');
            setOtp('');
            setNewPassword('');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    // ── Login / Register ────────────────────────────────────────────────────
    const handleAuth = async (e) => {
        e.preventDefault();
        clearMessages();
        setLoading(true);
        const endpoint = isRegistering ? '/register' : '/login';
        try {
            const res = await fetch(`${API_URL}${endpoint}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password, name }),
            });
            let data = {};
            try { data = await res.json(); } catch { /* empty/non-JSON body */ }
            if (!res.ok) throw new Error(data.error || `Server error (${res.status}). Is the backend running?`);
            if (isRegistering) {
                setSuccessMsg('Registration successful! Please sign in.');
                setIsRegistering(false);
            } else {
                saveToken(data.token, rememberMe);
                saveUserMeta(data.chat_id || '', data.user?.name || '', rememberMe);
                navigate('/home');
            }
        } catch (err) {
            if (err.message === 'Failed to fetch') {
                setError('Cannot reach the server. Make sure the backend is running (npx wrangler dev).');
            } else {
                setError(err.message);
            }
        } finally {
            setLoading(false);
        }
    };

    // ── Card header text ────────────────────────────────────────────────────
    const cardTitle = forgotStep === 'idle'
        ? (isRegistering ? 'Create Account' : 'Sign In')
        : forgotStep === 'sent' ? 'Verify OTP' : 'Sign In';

    const cardSubtitle = forgotStep === 'sent'
        ? `We sent a 6-digit OTP to ${email}`
        : forgotStep !== 'idle' ? ''
            : isRegistering ? 'Join us today!' : 'Welcome back! Please enter your details.';

    return (
        <div className="login-container">
            {/* Navbar */}
            <nav className="navbar">
                <div className="logo">
                    <div className="logo-icon">
                        <MessageSquare size={24} fill="white" color="white" />
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

                    {/* ── STEP 1: Enter email to get OTP ── */}
                    {forgotStep === 'idle' && (
                        <form className="login-form" onSubmit={handleAuth}>
                            {error && <div className="error-message" style={{ color: '#feb2b2', fontSize: '0.9rem' }}>{error}</div>}
                            {successMsg && <div style={{ color: '#9ae6b4', fontSize: '0.9rem', marginBottom: '0.5rem' }}>{successMsg}</div>}

                            <div className="input-group">
                                <Mail className="input-icon" size={20} />
                                <input type="email" placeholder="Your email" value={email}
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
                                    <button type="button" style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#63b3ed', fontSize: '0.85rem', padding: 0 }}
                                        onClick={() => { setForgotStep('sending'); clearMessages(); }}>
                                        Forgot password?
                                    </button>
                                    {/* Remember me */}
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

                    {/* ── STEP 1: Enter email for OTP ── */}
                    {forgotStep === 'sending' && (
                        <form className="login-form" onSubmit={handleSendOTP}>
                            {error && <div className="error-message" style={{ color: '#feb2b2', fontSize: '0.9rem' }}>{error}</div>}
                            <p style={{ color: '#a0aec0', fontSize: '0.9rem', marginBottom: '1rem' }}>
                                Enter your registered email and we'll send you a 6-digit OTP.
                            </p>
                            <div className="input-group">
                                <Mail className="input-icon" size={20} />
                                <input type="email" placeholder="Your registered email" value={email}
                                    onChange={(e) => setEmail(e.target.value)} required />
                            </div>
                            <button type="submit" className="signin-btn" disabled={loading}>
                                {loading ? 'Sending OTP...' : 'Send OTP'}
                            </button>
                            <button type="button" onClick={() => { setForgotStep('idle'); clearMessages(); }}
                                style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#a0aec0', fontSize: '0.85rem', marginTop: '0.5rem', width: '100%' }}>
                                ← Back to Sign In
                            </button>
                        </form>
                    )}

                    {/* ── STEP 2: Enter OTP + new password ── */}
                    {forgotStep === 'sent' && (
                        <form className="login-form" onSubmit={handleVerifyOTP}>
                            {error && <div className="error-message" style={{ color: '#feb2b2', fontSize: '0.9rem', marginBottom: '0.5rem' }}>{error}</div>}
                            {successMsg && <div style={{ color: '#9ae6b4', fontSize: '0.9rem', marginBottom: '0.5rem' }}>{successMsg}</div>}

                            <div className="input-group">
                                <ShieldCheck className="input-icon" size={20} />
                                <input type="text" placeholder="6-digit OTP" value={otp} maxLength={6}
                                    onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))} required
                                    style={{ letterSpacing: '0.3rem', fontWeight: 'bold', fontSize: '1.1rem' }} />
                            </div>

                            <div className="input-group">
                                <KeyRound className="input-icon" size={20} />
                                <input type="password" placeholder="New Password (min 6 chars)" value={newPassword}
                                    onChange={(e) => setNewPassword(e.target.value)} required minLength={6} />
                            </div>

                            <button type="submit" className="signin-btn" disabled={loading}>
                                {loading ? 'Verifying...' : 'Reset Password'}
                            </button>
                            <button type="button" onClick={() => { setForgotStep('sending'); clearMessages(); }}
                                style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#a0aec0', fontSize: '0.85rem', marginTop: '0.5rem', width: '100%' }}>
                                ← Resend OTP
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
