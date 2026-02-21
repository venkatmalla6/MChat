import React, { useEffect, useState, useRef } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { User, Mail, Calendar, ArrowLeft, LogOut, Hash, Camera } from 'lucide-react';
import { getToken, clearToken } from './auth';
import './Profile.css';

const API_URL = '/api';

// Compress + resize image to a base64 string
const compressImage = (file) => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
        const img = new Image();
        img.onload = () => {
            const MAX = 200; // max 200×200 px
            let { width, height } = img;
            if (width > height) { if (width > MAX) { height = (height * MAX) / width; width = MAX; } }
            else { if (height > MAX) { width = (width * MAX) / height; height = MAX; } }
            const canvas = document.createElement('canvas');
            canvas.width = Math.round(width);
            canvas.height = Math.round(height);
            canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
            resolve(canvas.toDataURL('image/jpeg', 0.82));
        };
        img.onerror = reject;
        img.src = e.target.result;
    };
    reader.onerror = reject;
    reader.readAsDataURL(file);
});

const Profile = () => {
    const navigate = useNavigate();
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [avatarUrl, setAvatarUrl] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [uploadMsg, setUploadMsg] = useState('');
    const fileInputRef = useRef(null);

    useEffect(() => {
        const fetchProfile = async () => {
            const token = getToken();
            if (!token) { navigate('/login'); return; }
            try {
                const response = await fetch(`${API_URL}/user`, {
                    headers: { Authorization: `Bearer ${token}` }
                });
                if (response.status === 401 || response.status === 403) {
                    localStorage.removeItem('token');
                    navigate('/login');
                    return;
                }
                if (!response.ok) throw new Error('Server error. Please try again later.');
                const data = await response.json();
                setUser(data);
                setAvatarUrl(data.avatar_url || null);
            } catch (err) {
                if (err.name === 'TypeError' && err.message === 'Failed to fetch') {
                    setError('Cannot connect to the server. Make sure the backend is running.');
                } else {
                    setError(err.message);
                }
            } finally {
                setLoading(false);
            }
        };
        fetchProfile();
    }, [navigate]);

    const handleAvatarChange = async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        if (!file.type.startsWith('image/')) { setUploadMsg('Please select an image file.'); return; }

        setUploading(true);
        setUploadMsg('');
        try {
            const compressed = await compressImage(file);
            const token = getToken();
            const res = await fetch(`${API_URL}/upload-avatar`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
                body: JSON.stringify({ avatar_url: compressed }),
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.error || 'Upload failed');
            setAvatarUrl(data.avatar_url);
            setUploadMsg('Profile picture updated! ✅');
        } catch (err) {
            setUploadMsg(err.message);
        } finally {
            setUploading(false);
            // Clear the input so the same file can be re-selected
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    const handleLogout = () => { clearToken(); navigate('/login'); };

    if (loading) return (
        <div className="profile-container loading">
            <div className="spinner"></div>
            <p>Loading profile...</p>
        </div>
    );

    if (error) return (
        <div className="profile-container error">
            <div className="error-card">
                <p>{error}</p>
                <button onClick={() => navigate('/login')}>Go to Login</button>
            </div>
        </div>
    );

    return (
        <div className="profile-container">
            <nav className="navbar">
                <Link to="/home" className="back-link">
                    <ArrowLeft size={20} /> Back to Home
                </Link>
                <h1 className="nav-title">My Profile</h1>
                <div style={{ width: '120px' }} />
            </nav>

            <div className="profile-content">
                <div className="profile-card">
                    <div className="profile-header">

                        {/* ── Clickable Avatar ── */}
                        <div className="avatar-wrapper" onClick={() => fileInputRef.current?.click()}>
                            <div className="avatar-large">
                                {avatarUrl
                                    ? <img src={avatarUrl} alt="Profile" style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: '50%' }} />
                                    : <User size={64} color="white" />
                                }
                            </div>
                            <div className="avatar-camera-overlay">
                                {uploading
                                    ? <div className="avatar-spin" />
                                    : <Camera size={22} color="white" />
                                }
                            </div>
                            <input
                                ref={fileInputRef}
                                type="file"
                                accept="image/*"
                                style={{ display: 'none' }}
                                onChange={handleAvatarChange}
                            />
                        </div>

                        {uploadMsg && (
                            <p style={{
                                fontSize: '0.82rem',
                                color: uploadMsg.includes('✅') ? '#68d391' : '#fc8181',
                                margin: 0,
                                textAlign: 'center',
                            }}>
                                {uploadMsg}
                            </p>
                        )}

                        <h2>{user.name || user.email.split('@')[0]}</h2>
                        <span className="badge">Member</span>
                    </div>

                    <div className="profile-details">
                        <div className="detail-item">
                            <User size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Full Name</label>
                                <p>{user.name || user.email.split('@')[0]}</p>
                            </div>
                        </div>
                        <div className="detail-item">
                            <Mail size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Email Address</label>
                                <p>{user.email}</p>
                            </div>
                        </div>
                        <div className="detail-item">
                            <Calendar size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Joined On</label>
                                <p>{new Date(user.joined).toLocaleDateString()}</p>
                            </div>
                        </div>
                        <div className="detail-item chat-id-item">
                            <Hash size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Your Chat ID <span style={{ color: '#4a5568', fontWeight: 400 }}>(share this to receive messages)</span></label>
                                <p className="mono chat-id-display">{user.chat_id || 'N/A'}</p>
                            </div>
                        </div>
                    </div>

                    <div className="profile-actions">
                        <button className="logout-btn-full" onClick={handleLogout}>
                            <LogOut size={20} /> Sign Out
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Profile;
