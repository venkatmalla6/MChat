import React from 'react';
import {
    MessageSquare, Users, Zap, CheckCheck, Edit, Trash2, Reply, Pin,
    Image, Video, Mic, FileText, Cloud,
    Shield, Lock, Key, Eye,
    User, Settings,
    Bell,
    Search, Archive, Ban,
    Moon, Smile,
    Server, Activity,
    Phone, Monitor
} from 'lucide-react';
import './Features.css';
import { Link } from 'react-router-dom';

const Features = () => {
    const features = [
        {
            category: "Core Messaging",
            icon: <MessageSquare size={32} className="feature-category-icon" />,
            items: [
                "1:1 Private Chat", "Group Chats", "Real-time Messaging (WebSocket)",
                "Message Status (Sent, Delivered, Read)", "Typing Indicators", "Online/Offline Presence",
                "Edit & Delete Messages", "Reply & Forward", "Pinned Messages"
            ]
        },
        {
            category: "Media & Sharing",
            icon: <Image size={32} className="feature-category-icon" />,
            items: [
                "Send Images, Videos, Audio", "Document Sharing (PDF, DOC)", "Media Preview",
                "No File Size Limits (within reason)", "Cloud Storage Integration (R2)"
            ]
        },
        {
            category: "Security",
            icon: <Shield size={32} className="feature-category-icon" />,
            items: [
                "End-to-End Encryption", "OAuth & Email Auth", "JWT Session Management",
                "Password Hashing (Argon2)", "Role-based Access Control"
            ]
        },
        {
            category: "User Profiles",
            icon: <User size={32} className="feature-category-icon" />,
            items: [
                "Custom Usernames & Avatars", "Bio/Status", "Last Seen Control",
                "Privacy Settings"
            ]
        },
        {
            category: "Group Features",
            icon: <Users size={32} className="feature-category-icon" />,
            items: [
                "Admin Roles", "Group Descriptions & Images", "Invite Links",
                "Granular Permissions"
            ]
        },
        {
            category: "Notifications",
            icon: <Bell size={32} className="feature-category-icon" />,
            items: [
                "Real-time In-app Alerts", "Push Notifications", "Email Notifications",
                "Mute Controls"
            ]
        },
        {
            category: "Chat Management",
            icon: <Search size={32} className="feature-category-icon" />,
            items: [
                "Global Search", "Archive & Clear Chats", "Block & Report Users"
            ]
        },
        {
            category: "UI/UX",
            icon: <Moon size={32} className="feature-category-icon" />,
            items: [
                "Dark Mode", "Responsive Design", "Emoji Picker", "Infinite Scroll",
                "Smooth Animations"
            ]
        },
        {
            category: "Performance",
            icon: <Activity size={32} className="feature-category-icon" />,
            items: [
                "Scalable Backend", "Message Indexing", "CDN for Media", "Redis Caching"
            ]
        },
        {
            category: "Advanced",
            icon: <Zap size={32} className="feature-category-icon" />,
            items: [
                "Voice & Video Calls (WebRTC)", "Screen Sharing", "Message Translation",
                "Multi-device Sync"
            ]
        }
    ];

    return (
        <div className="features-container">
            <nav className="navbar">
                <div className="logo">
                    <div className="logo-icon">
                        <MessageSquare size={24} fill="white" color="white" />
                    </div>
                    <span className="logo-text">MChat</span>
                </div>
                <div className="nav-links">
                    <Link to="/">Home</Link>
                    <Link to="/features" className="active">Features</Link>
                    <Link to="/about">About</Link>
                    <Link to="/login" className="signin-btn-nav">Sign In</Link>
                </div>
            </nav>

            <div className="features-header">
                <h1>Powerful Features for <span>Modern Communication</span></h1>
                <p>Everything you need to connect, collaborate, and chat securely.</p>
            </div>

            <div className="features-grid">
                {features.map((section, index) => (
                    <div key={index} className="feature-card">
                        <div className="feature-icon-wrapper">
                            {section.icon}
                        </div>
                        <h3>{section.category}</h3>
                        <ul>
                            {section.items.map((item, i) => (
                                <li key={i}>
                                    <CheckCheck size={16} className="check-icon" />
                                    {item}
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>

            <div className="features-cta">
                <h2>Ready to experience the future of chat?</h2>
                <Link to="/" className="btn-primary">Get Started Now</Link>
            </div>
        </div>
    );
};

export default Features;
