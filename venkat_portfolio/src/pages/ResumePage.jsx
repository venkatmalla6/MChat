import React, { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { ref, onValue } from 'firebase/database';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Download } from 'lucide-react';

const ResumePage = () => {
    const [resumeUrl, setResumeUrl] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const resumeRef = ref(db, 'profile/resumeUrl');
        onValue(resumeRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                setResumeUrl(data);
            }
            setLoading(false);
        });
    }, []);

    if (loading) {
        return (
            <div style={{
                height: '100vh',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                backgroundColor: '#1a1a1a',
                color: 'white'
            }}>
                <div className="spinner"></div>
            </div>
        );
    }

    if (!resumeUrl) {
        return (
            <div style={{
                height: '100vh',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'center',
                alignItems: 'center',
                backgroundColor: '#1a1a1a',
                color: 'white',
                gap: '1rem'
            }}>
                <p>No resume found.</p>
                <button onClick={() => navigate('/')} className="btn btn-primary">
                    Go Back
                </button>
            </div>
        );
    }

    return (
        <div style={{
            height: '100vh',
            width: '100vw',
            overflow: 'hidden',
            position: 'relative',
            backgroundColor: '#1a1a1a'
        }}>
            {/* Floating Navigation Controls */}
            <div style={{
                position: 'absolute',
                top: '20px',
                left: '20px',
                display: 'flex',
                gap: '10px',
                zIndex: 10
            }}>
                <button
                    onClick={() => navigate('/')}
                    className="btn btn-primary"
                    style={{
                        padding: '10px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '5px',
                        boxShadow: '0 4px 6px rgba(0,0,0,0.3)'
                    }}
                >
                    <ArrowLeft size={20} /> Back
                </button>
                <a
                    href={resumeUrl}
                    download="Venkat_Resume.pdf"
                    className="btn btn-primary"
                    style={{
                        padding: '10px',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '5px',
                        boxShadow: '0 4px 6px rgba(0,0,0,0.3)'
                    }}
                >
                    <Download size={20} /> Download
                </a>
            </div>

            <iframe
                src={resumeUrl}
                title="Resume"
                style={{
                    width: '100%',
                    height: '100%',
                    border: 'none',
                }}
            />
        </div>
    );
};

export default ResumePage;
