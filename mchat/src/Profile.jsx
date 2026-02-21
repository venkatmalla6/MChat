import React, { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { User, Mail, Calendar, ArrowLeft, LogOut, Hash } from 'lucide-react';
import './Profile.css';

const Profile = () => {
    const navigate = useNavigate();
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        const fetchProfile = async () => {
            const token = localStorage.getItem('token');
            if (!token) {
                navigate('/login');
                return;
            }

            try {
                const API_URL = '/api';
                const response = await fetch(`${API_URL}/user`, {
                    headers: {
                        'Authorization': `Bearer ${token}`
                    }
                });

                if (response.status === 401 || response.status === 403) {
                    // Token is invalid or expired — clear and redirect
                    localStorage.removeItem('token');
                    navigate('/login');
                    return;
                }

                if (!response.ok) {
                    throw new Error('Server error. Please try again later.');
                }

                const data = await response.json();
                setUser(data);
            } catch (err) {
                // Network error (e.g. worker not running or no internet)
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

    const handleLogout = () => {
        localStorage.removeItem('token');
        navigate('/login');
    };

    if (loading) {
        return (
            <div className="profile-container loading">
                <div className="spinner"></div>
                <p>Loading profile...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="profile-container error">
                <div className="error-card">
                    <p>{error}</p>
                    <button onClick={() => navigate('/login')}>Go to Login</button>
                </div>
            </div>
        );
    }

    return (
        <div className="profile-container">
            <nav className="navbar">
                <Link to="/" className="back-link">
                    <ArrowLeft size={20} /> Back to Home
                </Link>
                <h1 className="nav-title">My Profile</h1>
                <div style={{ width: '100px' }}></div> {/* Spacer */}
            </nav>

            <div className="profile-content">
                <div className="profile-card">
                    <div className="profile-header">
                        <div className="avatar-large">
                            <User size={64} color="white" />
                        </div>
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
