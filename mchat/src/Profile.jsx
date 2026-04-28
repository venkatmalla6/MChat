import React, { useEffect, useState, useRef } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { User, Mail, Calendar, ArrowLeft, LogOut, Hash, Camera } from 'lucide-react';
import { auth, db, storage } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { clearSession } from './auth';
import './Profile.css';

const Profile = () => {
    const navigate = useNavigate();
    const [user, setUser] = useState(null);         // Firestore user doc data
    const [fireUser, setFireUser] = useState(null); // Firebase Auth user
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [avatarUrl, setAvatarUrl] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [uploadMsg, setUploadMsg] = useState('');
    const fileInputRef = useRef(null);

    useEffect(() => {
        const unsub = onAuthStateChanged(auth, async (firebaseUser) => {
            if (!firebaseUser) {
                navigate('/login');
                return;
            }
            setFireUser(firebaseUser);
            try {
                const snap = await getDoc(doc(db, 'users', firebaseUser.uid));
                if (snap.exists()) {
                    const data = snap.data();
                    setUser(data);
                    setAvatarUrl(data.avatar_url || null);
                } else {
                    setError('User profile not found in database.');
                }
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        });
        return () => unsub();
    }, [navigate]);

    const handleAvatarChange = async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;
        if (!file.type.startsWith('image/')) { setUploadMsg('Please select an image file.'); return; }

        setUploading(true);
        setUploadMsg('');
        try {
            // Upload to Firebase Storage: avatars/{uid}/avatar
            const storageRef = ref(storage, `avatars/${fireUser.uid}/avatar`);
            await uploadBytes(storageRef, file);
            const downloadURL = await getDownloadURL(storageRef);

            // Update Firestore user doc
            await updateDoc(doc(db, 'users', fireUser.uid), { avatar_url: downloadURL });
            setAvatarUrl(downloadURL);
            setUploadMsg('Profile picture updated! ✅');
        } catch (err) {
            setUploadMsg(err.message);
        } finally {
            setUploading(false);
            if (fileInputRef.current) fileInputRef.current.value = '';
        }
    };

    const handleLogout = async () => {
        await clearSession();
        navigate('/login');
    };

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

    const displayName = user?.name || fireUser?.email?.split('@')[0] || 'User';
    const joinedDate = user?.created_at?.toDate
        ? user.created_at.toDate().toLocaleDateString()
        : (fireUser?.metadata?.creationTime
            ? new Date(fireUser.metadata.creationTime).toLocaleDateString()
            : 'N/A');

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

                        <h2>{displayName}</h2>
                        <span className="badge">Member</span>
                    </div>

                    <div className="profile-details">
                        <div className="detail-item">
                            <User size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Full Name</label>
                                <p>{displayName}</p>
                            </div>
                        </div>
                        <div className="detail-item">
                            <Mail size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Email Address</label>
                                <p>{user?.email || fireUser?.email}</p>
                            </div>
                        </div>
                        <div className="detail-item">
                            <Calendar size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Joined On</label>
                                <p>{joinedDate}</p>
                            </div>
                        </div>
                        <div className="detail-item chat-id-item">
                            <Hash size={20} className="detail-icon" />
                            <div className="detail-text">
                                <label>Your Chat ID <span style={{ color: '#4a5568', fontWeight: 400 }}>(share this to receive messages)</span></label>
                                <p className="mono chat-id-display">{user?.chat_id || 'N/A'}</p>
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
