import React, { useState, useEffect, useRef } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { MessageSquare, Send, User, LogOut, ArrowLeft, Hash, Search, X, Star } from 'lucide-react';
import { auth, db } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';
import {
    collection,
    query,
    where,
    onSnapshot,
    addDoc,
    serverTimestamp,
    getDocs,
    limit,
    updateDoc
} from 'firebase/firestore';
import { clearSession } from './auth';
import './Chat.css';

/** Returns a stable conversation ID from two UIDs (always same regardless of who sends first) */
const convId = (uid1, uid2) => [uid1, uid2].sort().join('_');

const Chat = () => {
    const navigate = useNavigate();
    const location = useLocation();

    const [fireUser, setFireUser] = useState(null); // Firebase Auth user
    const [currentUser, setCurrentUser] = useState({ email: '', name: '', uid: '' });
    const [messages, setMessages] = useState([]);
    const [input, setInput] = useState('');
    const [sending, setSending] = useState(false);
    const [receiver, setReceiver] = useState(null); // { email, name, chat_id, uid }
    const messagesEndRef = useRef(null);
    const inputRef = useRef(null);
    // Tracks whether we've already run the one-time receiver restoration
    const initializedRef = useRef(false);

    // Modal state
    const [showModal, setShowModal] = useState(false);
    const [chatIdInput, setChatIdInput] = useState('');
    const [lookupError, setLookupError] = useState('');
    const [looking, setLooking] = useState(false);

    // Conversations & starred
    const [conversations, setConversations] = useState([]);
    const [starred, setStarred] = useState(() => {
        try { return JSON.parse(localStorage.getItem('starred_convs') || '[]'); }
        catch { return []; }
    });

    const toggleStar = (e, email) => {
        e.stopPropagation();
        setStarred(prev => {
            const next = prev.includes(email)
                ? prev.filter(x => x !== email)
                : [...prev, email];
            localStorage.setItem('starred_convs', JSON.stringify(next));
            return next;
        });
    };

    const openConv = (conv) => {
        setReceiver(conv);
        localStorage.setItem('last_receiver', JSON.stringify(conv));
        setShowModal(false);
    };

    // ── Auth guard ────────────────────────────────────────────────────────────
    useEffect(() => {
        const unsub = onAuthStateChanged(auth, (user) => {
            if (!user) { navigate('/login'); return; }
            setFireUser(user);
            setCurrentUser({
                email: user.email,
                name: user.displayName || user.email.split('@')[0],
                uid: user.uid,
            });
        });
        return () => unsub();
    }, [navigate]);

    // ── Restore last receiver / location state (runs ONCE after auth resolves) ──
    useEffect(() => {
        if (!fireUser) return;
        // Guard: only initialise once. Firebase can re-fire onAuthStateChanged
        // with a refreshed user object, which would reset the receiver state.
        if (initializedRef.current) return;
        initializedRef.current = true;

        if (location.state?.receiver) {
            setReceiver(location.state.receiver);
            setShowModal(false);
            return;
        }
        if (location.state?.openInbox) {
            setShowModal(false);
            return;
        }
        try {
            const saved = localStorage.getItem('last_receiver');
            if (saved) { setReceiver(JSON.parse(saved)); setShowModal(false); return; }
        } catch { /* ignore */ }
        setShowModal(true);
    }, [fireUser, location.state]);

    // ── Scroll to bottom ──────────────────────────────────────────────────────
    useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }, [messages]);

    // ── Realtime: conversations (unique partners via participants array) ─────────
    useEffect(() => {
        if (!fireUser) return;

        // 'participants' is an array stored on every message — no or() needed
        const q = query(
            collection(db, 'messages'),
            where('participants', 'array-contains', fireUser.uid)
        );

        const unsub = onSnapshot(q, (snap) => {
            const partnerMap = new Map();
            snap.forEach(d => {
                const data = d.data();
                const isSender = data.sender_uid === fireUser.uid;
                const partnerUid = isSender ? data.receiver_uid : data.sender_uid;
                const partnerEmail = isSender ? data.receiver_email : data.sender_email;
                const partnerName = isSender ? data.receiver_name : data.sender_name;
                const partnerChatId = isSender ? data.receiver_chat_id : data.sender_chat_id;
                const ts = data.created_at?.seconds || 0;

                if (!partnerMap.has(partnerUid) || ts > (partnerMap.get(partnerUid).last_msg || 0)) {
                    partnerMap.set(partnerUid, {
                        uid: partnerUid,
                        email: partnerEmail,
                        name: partnerName,
                        chat_id: partnerChatId,
                        last_msg: ts,
                    });
                }
            });
            const sorted = [...partnerMap.values()].sort((a, b) => b.last_msg - a.last_msg);
            setConversations(sorted);
        });

        return () => unsub();
    }, [fireUser]);

    // ── Realtime: messages with current receiver ──────────────────────────────
    useEffect(() => {
        if (!fireUser || !receiver) return;

        // No orderBy in the query — serverTimestamp() is null on the client
        // until the server confirms it, so orderBy would skip pending messages.
        // We sort client-side instead so new messages appear the instant they
        // are written, even before the server acknowledges them.
        const cid = convId(fireUser.uid, receiver.uid);
        const q = query(
            collection(db, 'messages'),
            where('conversation_id', '==', cid),
            limit(200)
        );

        const unsub = onSnapshot(q, { includeMetadataChanges: true }, (snap) => {
            const msgs = snap.docs
                .map(d => ({ id: d.id, ...d.data(), ref: d.ref }))
                // Sort by created_at; pending writes have null — put them last so
                // they still show immediately at the bottom.
                .sort((a, b) => {
                    const ta = a.created_at?.seconds ?? Infinity;
                    const tb = b.created_at?.seconds ?? Infinity;
                    return ta - tb;
                });
            setMessages(msgs);
        }, (err) => {
            console.error('Messages listener error:', err);
        });

        return () => unsub();
    }, [fireUser, receiver]);

    // ── Mark messages as read ─────────────────────────────────────────────────
    useEffect(() => {
        if (!fireUser || !receiver) return;
        messages.forEach(msg => {
            if (msg.receiver_uid === fireUser.uid && msg.is_read === false && msg.ref) {
                updateDoc(msg.ref, { is_read: true }).catch(err => console.error(err));
            }
        });
    }, [messages, fireUser, receiver]);

    // ── Lookup user by Chat ID ────────────────────────────────────────────────
    const handleLookup = async (e) => {
        e.preventDefault();
        setLookupError('');
        setLooking(true);
        try {
            const q = query(
                collection(db, 'users'),
                where('chat_id', '==', chatIdInput.trim().toUpperCase()),
                limit(1)
            );
            const snap = await getDocs(q);
            if (snap.empty) throw new Error('No user found with that Chat ID.');
            const data = snap.docs[0].data();
            const uid = snap.docs[0].id;
            if (uid === fireUser.uid) throw new Error("That's your own Chat ID!");
            openConv({ uid, email: data.email, name: data.name, chat_id: data.chat_id });
        } catch (err) {
            setLookupError(err.message);
        } finally {
            setLooking(false);
        }
    };

    // ── Send message ──────────────────────────────────────────────────────────
    const handleSend = async (e) => {
        e.preventDefault();
        if (!input.trim() || sending || !receiver) return;
        setSending(true);
        try {
            await addDoc(collection(db, 'messages'), {
                // conversation_id lets us query with a single where() + orderBy()
                conversation_id: convId(fireUser.uid, receiver.uid),
                // participants array lets us query all conversations for a user
                participants: [fireUser.uid, receiver.uid],
                sender_uid: fireUser.uid,
                sender_email: currentUser.email,
                sender_name: currentUser.name,
                sender_chat_id: null,
                receiver_uid: receiver.uid,
                receiver_email: receiver.email,
                receiver_name: receiver.name,
                receiver_chat_id: receiver.chat_id,
                content: input.trim(),
                created_at: serverTimestamp(),
                is_read: false,
            });
            setInput('');
        } catch (err) {
            console.error('Send error:', err);
        } finally {
            setSending(false);
            inputRef.current?.focus();
        }
    };

    const handleLogout = async () => { await clearSession(); navigate('/login'); };
    const formatTime = (ts) => {
        if (!ts) return '';
        const d = ts.seconds ? new Date(ts.seconds * 1000) : new Date(ts);
        return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    };

    const starredConvs = conversations.filter(c => starred.includes(c.email));
    const otherConvs = conversations.filter(c => !starred.includes(c.email));

    const ConvItem = ({ conv }) => (
        <div
            className={`channel-item ${receiver?.email === conv.email ? 'active' : ''}`}
            onClick={() => openConv(conv)}
            style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}
        >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', flex: 1, minWidth: 0 }}>
                <div className="dm-avatar">{conv.name?.[0]?.toUpperCase() || '?'}</div>
                <div className="dm-info" style={{ minWidth: 0 }}>
                    <span className="dm-name">{conv.name}</span>
                    <span className="dm-chatid">{conv.chat_id}</span>
                </div>
            </div>
            <button
                title={starred.includes(conv.email) ? 'Unstar' : 'Star'}
                onClick={(e) => toggleStar(e, conv.email)}
                style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    padding: '2px', flexShrink: 0,
                    color: starred.includes(conv.email) ? '#f6c90e' : '#4a5568',
                    transition: 'color 0.2s',
                }}
            >
                <Star size={14} fill={starred.includes(conv.email) ? '#f6c90e' : 'none'} />
            </button>
        </div>
    );

    return (
        <div className="chat-page">
            {/* Chat ID Lookup Modal */}
            {showModal && (
                <div className="modal-overlay">
                    <div className="modal-box">
                        <div className="modal-icon"><MessageSquare size={32} color="#4299e1" /></div>
                        <h2>Start a Conversation</h2>
                        <p>Enter the <strong>Chat ID</strong> of the person you want to message.<br />
                            Their Chat ID is shown on their Profile page.</p>
                        <form onSubmit={handleLookup} className="modal-form">
                            <div className="modal-input-wrap">
                                <Hash size={18} className="modal-input-icon" />
                                <input
                                    type="text" placeholder="e.g. A1B2C3"
                                    value={chatIdInput}
                                    onChange={e => setChatIdInput(e.target.value.toUpperCase())}
                                    maxLength={6} autoFocus required
                                    style={{ textTransform: 'uppercase', letterSpacing: '0.15rem', fontWeight: 600 }}
                                />
                            </div>
                            {lookupError && <p className="modal-error">{lookupError}</p>}
                            <button type="submit" className="modal-btn" disabled={looking || !chatIdInput.trim()}>
                                {looking ? 'Looking up...' : <><Search size={16} /> Find &amp; Chat</>}
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
                        <div className="logo-icon"><MessageSquare size={20} fill="white" color="white" /></div>
                        <span className="logo-text">MChat</span>
                    </div>
                </div>

                <div className="sidebar-section" style={{ flex: 1, overflowY: 'auto' }}>

                    {/* ── STARRED ── */}
                    {starredConvs.length > 0 && (
                        <>
                            <p className="sidebar-label" style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
                                <Star size={12} fill="#f6c90e" color="#f6c90e" /> STARRED
                            </p>
                            {starredConvs.map(conv => <ConvItem key={conv.email} conv={conv} />)}
                            <div style={{ height: '1px', background: '#2d3748', margin: '0.5rem 0.75rem' }} />
                        </>
                    )}

                    {/* ── ALL MESSAGES ── */}
                    <p className="sidebar-label">DIRECT MESSAGES</p>
                    {conversations.length === 0 && (
                        <p style={{ color: '#4a5568', fontSize: '0.78rem', padding: '0.5rem 0.75rem' }}>
                            No conversations yet.<br />Start one with "+ New Chat"
                        </p>
                    )}
                    {otherConvs.map(conv => <ConvItem key={conv.email} conv={conv} />)}

                    <button className="new-chat-btn" onClick={() => { setShowModal(true); setChatIdInput(''); setLookupError(''); }}>
                        + New Chat
                    </button>
                </div>

                <div className="sidebar-bottom">
                    <div className="user-chip">
                        <div className="user-avatar-sm"><User size={14} color="white" /></div>
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
                                <button
                                    title={starred.includes(receiver.email) ? 'Unstar conversation' : 'Star conversation'}
                                    onClick={(e) => toggleStar(e, receiver.email)}
                                    style={{
                                        background: 'none', border: 'none', cursor: 'pointer',
                                        marginLeft: '0.75rem', padding: '4px',
                                        color: starred.includes(receiver.email) ? '#f6c90e' : '#4a5568',
                                        transition: 'color 0.2s, transform 0.15s',
                                    }}
                                >
                                    <Star
                                        size={20}
                                        fill={starred.includes(receiver.email) ? '#f6c90e' : 'none'}
                                        style={{ transition: 'fill 0.2s' }}
                                    />
                                </button>
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
                            <p>Select a conversation or enter a Chat ID to start messaging</p>
                        </div>
                    )}
                    {receiver && messages.length === 0 && (
                        <div className="empty-chat">
                            <MessageSquare size={48} color="#4a5568" />
                            <p>No messages yet. Say hello to {receiver.name}! 👋</p>
                        </div>
                    )}
                    {messages.map((msg, i) => {
                        const isMe = msg.sender_uid === fireUser?.uid;
                        const showAvatar = i === 0 || messages[i - 1]?.sender_uid !== msg.sender_uid;
                        return (
                            <div key={msg.id} className={`message-row ${isMe ? 'me' : 'them'}`}>
                                {!isMe && (
                                    <div className={`msg-avatar ${showAvatar ? '' : 'invisible'}`}>
                                        {msg.sender_name?.[0]?.toUpperCase() || '?'}
                                    </div>
                                )}
                                <div className="message-group">
                                    {showAvatar && !isMe && <span className="msg-sender">{msg.sender_name}</span>}
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
