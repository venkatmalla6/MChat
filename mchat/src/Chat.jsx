import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { MessageSquare, Send, User, LogOut, ArrowLeft, Hash, Search, X } from 'lucide-react';
import './Chat.css';

const API_URL = '/api';

const Chat = () => {
    const navigate = useNavigate();
    const [currentUser, setCurrentUser] = useState({ email: '', name: '' });
    const [messages, setMessages] = useState([]);
    const [input, setInput] = useState('');
    const [sending, setSending] = useState(false);
    const [receiver, setReceiver] = useState(null); // { email, name, chat_id }
    const messagesEndRef = useRef(null);
    const inputRef = useRef(null);

    // Chat ID lookup modal state
    const [showModal, setShowModal] = useState(true);
    const [chatIdInput, setChatIdInput] = useState('');
    const [lookupError, setLookupError] = useState('');
    const [looking, setLooking] = useState(false);

    // Get current user from token
    useEffect(() => {
        const token = localStorage.getItem('token');
        if (!token) { navigate('/login'); return; }
        try {
            const payload = JSON.parse(atob(token));
            setCurrentUser({ email: payload.email, name: payload.email.split('@')[0] });
        } catch { navigate('/login'); }
    }, [navigate]);

    // Scroll to bottom
    useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [messages]);

    // Fetch DMs — receiver passed explicitly to avoid stale closure in setInterval
    const fetchMessages = async (target) => {
        if (!target) return;
        const token = localStorage.getItem('token');
        try {
            const res = await fetch(`${API_URL}/messages?with=${encodeURIComponent(target.email)}`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            if (!res.ok) return;
            const data = await res.json();
            setMessages(data.messages || []);
        } catch { /* silent */ }
    };

    useEffect(() => {
        if (!receiver) return;
        fetchMessages(receiver);
        const interval = setInterval(() => fetchMessages(receiver), 2000);
        return () => clearInterval(interval);
    }, [receiver]);

    // Lookup user by Chat ID
    const handleLookup = async (e) => {
        e.preventDefault();
        setLookupError('');
        setLooking(true);
        const token = localStorage.getItem('token');
        try {
            const res = await fetch(`${API_URL}/user-by-chatid?chat_id=${chatIdInput.trim().toUpperCase()}`, {
                headers: { Authorization: `Bearer ${token}` },
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'User not found');
            // Can't chat with yourself
            const payload = JSON.parse(atob(token));
            if (data.email === payload.email) {
                throw new Error("That's your own Chat ID! Enter someone else's.");
            }
            setReceiver(data);
            setShowModal(false);
        } catch (err) {
            setLookupError(err.message);
        } finally {
            setLooking(false);
        }
    };

    // Send message
    const handleSend = async (e) => {
        e.preventDefault();
        if (!input.trim() || sending || !receiver) return;
        setSending(true);
        const token = localStorage.getItem('token');
        try {
            await fetch(`${API_URL}/messages`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
                body: JSON.stringify({ content: input.trim(), receiver_email: receiver.email }),
            });
            setInput('');
            await fetchMessages(receiver);
        } catch { /* silent */ } finally {
            setSending(false);
            inputRef.current?.focus();
        }
    };

    const handleLogout = () => { localStorage.removeItem('token'); navigate('/login'); };

    const formatTime = (ts) => new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    return (
        <div className="chat-page">
            {/* Chat ID Lookup Modal */}
            {showModal && (
                <div className="modal-overlay">
                    <div className="modal-box">
                        <div className="modal-icon">
                            <MessageSquare size={32} color="#4299e1" />
                        </div>
                        <h2>Start a Conversation</h2>
                        <p>Enter the <strong>Chat ID</strong> of the person you want to message.<br />
                            Their Chat ID is shown on their Profile page.</p>

                        <form onSubmit={handleLookup} className="modal-form">
                            <div className="modal-input-wrap">
                                <Hash size={18} className="modal-input-icon" />
                                <input
                                    type="text"
                                    placeholder="e.g. MCH4F2A"
                                    value={chatIdInput}
                                    onChange={e => setChatIdInput(e.target.value.toUpperCase())}
                                    maxLength={10}
                                    autoFocus
                                    required
                                    style={{ textTransform: 'uppercase', letterSpacing: '0.15rem', fontWeight: 600 }}
                                />
                            </div>
                            {lookupError && <p className="modal-error">{lookupError}</p>}
                            <button type="submit" className="modal-btn" disabled={looking || !chatIdInput.trim()}>
                                {looking ? 'Looking up...' : <><Search size={16} /> Find & Chat</>}
                            </button>
                        </form>

                        <button className="modal-back" onClick={() => navigate('/home')}>
                            <ArrowLeft size={14} /> Back to Home
                        </button>
                    </div>
                </div>
            )}

            {/* Sidebar */}
            <aside className="chat-sidebar">
                <div className="sidebar-header">
                    <div className="logo">
                        <div className="logo-icon">
                            <MessageSquare size={20} fill="white" color="white" />
                        </div>
                        <span className="logo-text">MChat</span>
                    </div>
                </div>

                <div className="sidebar-section">
                    <p className="sidebar-label">DIRECT MESSAGES</p>
                    {receiver && (
                        <div className="channel-item active">
                            <div className="dm-avatar">{receiver.name?.[0]?.toUpperCase() || '?'}</div>
                            <div className="dm-info">
                                <span className="dm-name">{receiver.name}</span>
                                <span className="dm-chatid">{receiver.chat_id}</span>
                            </div>
                        </div>
                    )}
                    <button className="new-chat-btn" onClick={() => { setShowModal(true); setChatIdInput(''); setLookupError(''); }}>
                        + New Chat
                    </button>
                </div>

                <div className="sidebar-bottom">
                    <div className="user-chip">
                        <div className="user-avatar-sm">
                            <User size={14} color="white" />
                        </div>
                        <span className="user-email-sm">{currentUser.email.split('@')[0]}</span>
                    </div>
                    <div className="sidebar-nav-links">
                        <Link to="/home" className="sidebar-link"><ArrowLeft size={16} /> Home</Link>
                        <button className="sidebar-link logout" onClick={handleLogout}><LogOut size={16} /> Logout</button>
                    </div>
                </div>
            </aside>

            {/* Main Chat */}
            <main className="chat-main">
                <header className="chat-header-bar">
                    <div className="chat-header-left">
                        {receiver ? (
                            <>
                                <div className="header-dm-avatar">{receiver.name?.[0]?.toUpperCase()}</div>
                                <div>
                                    <h2>{receiver.name}</h2>
                                    <p>Chat ID: {receiver.chat_id}</p>
                                </div>
                            </>
                        ) : (
                            <h2>Select a conversation</h2>
                        )}
                    </div>
                    {receiver && (
                        <button className="change-btn" onClick={() => { setShowModal(true); setChatIdInput(''); setLookupError(''); }}>
                            <X size={16} /> Change
                        </button>
                    )}
                </header>

                <div className="messages-area">
                    {!receiver && (
                        <div className="empty-chat">
                            <MessageSquare size={48} color="#4a5568" />
                            <p>Enter a Chat ID to start messaging</p>
                        </div>
                    )}

                    {receiver && messages.length === 0 && (
                        <div className="empty-chat">
                            <MessageSquare size={48} color="#4a5568" />
                            <p>No messages yet. Say hello to {receiver.name}! 👋</p>
                        </div>
                    )}

                    {messages.map((msg, i) => {
                        const isMe = msg.sender_email === currentUser.email;
                        const showAvatar = i === 0 || messages[i - 1]?.sender_email !== msg.sender_email;
                        return (
                            <div key={msg.id} className={`message-row ${isMe ? 'me' : 'them'}`}>
                                {!isMe && (
                                    <div className={`msg-avatar ${showAvatar ? '' : 'invisible'}`}>
                                        {msg.sender_name?.[0]?.toUpperCase() || '?'}
                                    </div>
                                )}
                                <div className="message-group">
                                    {showAvatar && !isMe && (
                                        <span className="msg-sender">{msg.sender_name}</span>
                                    )}
                                    <div className="msg-bubble-wrap">
                                        <div className={`msg-bubble ${isMe ? 'bubble-me' : 'bubble-them'}`}>
                                            {msg.content}
                                        </div>
                                        <span className="msg-time">{formatTime(msg.created_at)}</span>
                                    </div>
                                </div>
                                {isMe && (
                                    <div className={`msg-avatar avatar-me ${showAvatar ? '' : 'invisible'}`}>
                                        {currentUser.email[0]?.toUpperCase()}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                    <div ref={messagesEndRef} />
                </div>

                {receiver && (
                    <form className="chat-input-bar" onSubmit={handleSend}>
                        <input
                            ref={inputRef}
                            className="chat-input"
                            type="text"
                            placeholder={`Message ${receiver.name}...`}
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            autoComplete="off"
                        />
                        <button type="submit" className="send-btn" disabled={!input.trim() || sending}>
                            <Send size={20} />
                        </button>
                    </form>
                )}
            </main>
        </div>
    );
};

export default Chat;
