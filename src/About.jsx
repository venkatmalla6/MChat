import React from 'react';
import {
    MessageSquare, Shield, Globe, Award, Mail,
    CheckCircle, Lock, Server, Zap
} from 'lucide-react';
import './About.css';
import { Link } from 'react-router-dom';

const About = () => {
    return (
        <div className="about-container">
            <nav className="navbar">
                <div className="logo">
                    <div className="logo-icon">
                        <MessageSquare size={24} fill="white" color="white" />
                    </div>
                    <span className="logo-text">MChat</span>
                </div>
                <div className="nav-links">
                    <Link to="/">Home</Link>
                    <Link to="/features">Features</Link>
                    <Link to="/about" className="active">About</Link>
                    <Link to="/login" className="signin-btn-nav">Sign In</Link>
                </div>
            </nav>

            <div className="about-content">
                <div className="about-header">
                    <h1>About <span>MChat</span></h1>
                    <p className="version-badge">Version 1.0.0</p>
                    <p className="mission-statement">
                        MChat is a real-time messaging application designed for fast, secure, and reliable communication.
                        We connect people through private chats and group conversations with seamless media sharing.
                    </p>
                </div>

                <div className="about-grid">
                    <div className="about-card">
                        <Zap size={40} className="about-icon" />
                        <h3>Key Features</h3>
                        <ul>
                            <li><CheckCircle size={16} /> Instant real-time messaging</li>
                            <li><CheckCircle size={16} /> Private and group chats</li>
                            <li><CheckCircle size={16} /> Media sharing (Images, Video, Audio)</li>
                            <li><CheckCircle size={16} /> Message read receipts</li>
                            <li><CheckCircle size={16} /> Cloud-based media storage</li>
                        </ul>
                    </div>

                    <div className="about-card">
                        <Shield size={40} className="about-icon" />
                        <h3>Security & Privacy</h3>
                        <p>
                            MChat uses secure authentication methods and encrypted data handling to protect your information.
                            Your data is handled responsibly and is never shared with third parties.
                        </p>
                        <div className="security-badges">
                            <span className="badge"><Lock size={14} /> Secure Auth</span>
                            <span className="badge"><Server size={14} /> Encrypted Data</span>
                        </div>
                    </div>

                    <div className="about-card">
                        <Globe size={40} className="about-icon" />
                        <h3>Built With</h3>
                        <ul>
                            <li><CheckCircle size={16} /> Modern Web Technologies (React)</li>
                            <li><CheckCircle size={16} /> Scalable Backend Architecture (Cloudflare Workers)</li>
                            <li><CheckCircle size={16} /> Secure Cloud Storage (R2)</li>
                        </ul>
                    </div>
                </div>

                <div className="contact-section">
                    <h2>Get in Touch</h2>
                    <p>Have questions, feedback, or need support?</p>
                    <a href="mailto:support@mchatapp.com" className="contact-link">
                        <Mail size={20} /> support@mchatapp.com
                    </a>
                </div>
            </div>

            <div className="about-footer">
                <p>&copy; {new Date().getFullYear()} MChat. All rights reserved.</p>
            </div>
        </div>
    );
};

export default About;
