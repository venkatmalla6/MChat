import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { MessageSquare, Zap, Briefcase, Shield, FileText, X, User, MoreHorizontal, Paperclip, Send, LogOut } from 'lucide-react';
import './Home.css';

const Home = () => {
    const navigate = useNavigate();
    const [unreadCount, setUnreadCount] = useState(0);

    const handleLogout = () => {
        localStorage.removeItem('token');
        navigate('/login');
    };

    // Poll for unread message count every 5 seconds
    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) return;

        const checkUnread = async () => {
            try {
                const res = await fetch('/api/messages/unread-count', {
                    headers: { Authorization: `Bearer ${token}` },
                });
                if (!res.ok) return;
                const data = await res.json();
                setUnreadCount(data.count || 0);
            } catch { /* silent */ }
        };

        checkUnread();
        const interval = setInterval(checkUnread, 5000);
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="home-container">
            {/* Navbar */}
            <nav className="navbar">
                <div className="logo">
                    <div className="logo-icon">
                        <MessageSquare size={24} fill="white" color="white" />
                    </div>
                    <span className="logo-text">MChat</span>
                </div>
                <div className="nav-links">
                    <button className="icon-btn-nav" onClick={() => navigate('/profile')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'white', marginRight: '1rem' }}>
                        <User size={24} />
                    </button>
                    <button className="logout-btn-nav" onClick={handleLogout} style={{ background: 'none', border: '1px solid rgba(255,255,255,0.2)', padding: '0.5rem 1rem', borderRadius: '8px', cursor: 'pointer', color: '#feb2b2', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <LogOut size={18} /> Logout
                    </button>
                </div>
            </nav>

            {/* Hero Section */}
            <div className="hero-section">
                <h1 className="hero-title">Connect Instantly with <span>MChat</span></h1>
                <p className="hero-subtitle">Real-Time Chat &amp; File Sharing Made Easy</p>

                <div className="hero-buttons">
                    <button className="btn-primary" onClick={() => navigate('/chat')}>
                        💬 Open Chat
                    </button>
                </div>

                {/* Main Illustration Area */}
                <div className="illustration-container">
                    <div className="man-illustration">
                        <div className="man-body-shape"></div>
                        <div className="man-head-shape"></div>
                        <div className="laptop-shape"></div>
                        <div className="headphones-shape"></div>
                    </div>

                    <div className="chat-interfaces">
                        <div className="chat-card card-left">
                            <div className="card-header-small">
                                <div className="icon-lock-small"></div>
                                <span>Groups</span>
                            </div>
                            <div className="group-list">
                                <div className="group-item active">
                                    <div className="avatar small"></div>
                                    <span>Friends Chat</span>
                                </div>
                                <div className="group-item">
                                    <div className="avatar small green"></div>
                                    <span>Project Team</span>
                                </div>
                                <div className="group-item">
                                    <div className="avatar small blue"></div>
                                    <span>Study Group</span>
                                </div>
                            </div>
                        </div>

                        <div className="chat-card card-center">
                            <div className="chat-header">
                                <div className="user-info">
                                    <div className="avatar red"></div>
                                    <span>Alex</span>
                                </div>
                                <MoreHorizontal size={16} color="#718096" />
                            </div>
                            <div className="chat-body">
                                <div className="message received"><p>Hey, did you get the latest report?</p></div>
                                <div className="message sent"><p>Yes, I'll check it out now!</p></div>
                                <div className="message file-attachment">
                                    <FileText size={24} color="#e53e3e" />
                                    <div className="file-info">
                                        <span className="file-name">report.pdf</span>
                                        <span className="file-size">2.5 MB Download</span>
                                    </div>
                                </div>
                                <div className="message received"><p>Sure, I'll have a look</p></div>
                            </div>
                            <div className="chat-input-area">
                                <div className="input-placeholder"></div>
                                <div className="input-actions">
                                    <Paperclip size={14} color="#a0aec0" />
                                    <Send size={14} color="#4299e1" />
                                </div>
                            </div>
                        </div>

                        <div className="chat-card card-right">
                            <div className="chat-header dark">
                                <div className="header-left">
                                    <div className="icon-lock-orange"></div>
                                    <span>Data Team Chat</span>
                                </div>
                                <div className="header-actions">
                                    <User size={14} color="white" />
                                    <X size={14} color="white" />
                                </div>
                            </div>
                            <div className="chat-body">
                                <div className="message received">
                                    <div className="avatar-xs"></div>
                                    <p>John: The data is updated!</p>
                                </div>
                                <div className="typing-indicator"><span>Sarah is typing...</span></div>
                                <div className="upload-preview"><div className="cloud-upload-icon"></div></div>
                            </div>
                        </div>
                    </div>

                    <div className="woman-illustration">
                        <div className="woman-body-shape"></div>
                        <div className="woman-head-shape"></div>
                        <div className="woman-hair-shape"></div>
                        <div className="phone-shape"></div>
                    </div>

                    <div className="floating-elements">
                        <div className="float-msg msg-1"></div>
                        <div className="float-msg msg-2"></div>
                        <div className="float-file file-1"></div>
                        <div className="cloud-large-right"></div>
                    </div>
                </div>
            </div>

            {/* Features Footer */}
            <div className="features-footer">
                <div className="feature">
                    <div className="feature-icon bolt"><Zap size={20} color="white" fill="white" /></div>
                    <div className="feature-text"><h3>Real-Time</h3><p>Messaging</p></div>
                </div>
                <div className="feature">
                    <div className="feature-icon briefcase"><Briefcase size={20} color="white" fill="white" /></div>
                    <div className="feature-text"><h3>Easy File</h3><p>Sharing</p></div>
                </div>
                <div className="feature">
                    <div className="feature-icon shield"><Shield size={20} color="white" fill="white" /></div>
                    <div className="feature-text"><h3>Secure &amp;</h3><p>Reliable</p></div>
                </div>
            </div>

            <div className="bg-wave-bottom"></div>

            {/* ── Floating chat button — appears only when there are unread messages ── */}
            {unreadCount > 0 && (
                <button
                    className="fab-chat"
                    onClick={() => navigate('/chat')}
                    title={`${unreadCount} new message${unreadCount > 1 ? 's' : ''}`}
                >
                    <MessageSquare size={26} fill="white" color="white" />
                    <span className="fab-badge">{unreadCount > 99 ? '99+' : unreadCount}</span>
                </button>
            )}
        </div>
    );
};

export default Home;
