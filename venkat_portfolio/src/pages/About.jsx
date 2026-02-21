import { motion } from 'framer-motion';
import '../styles/about.css';
import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { ref, onValue, set } from 'firebase/database';
import { Edit2, Save, X } from 'lucide-react';

const About = () => {
    const [aboutData, setAboutData] = useState({
        title: 'About Me',
        subtitle: 'Passion for building scalable web applications and cloud infrastructure.',
        bio: 'I am a dedicated AWS & DevOps Engineer with a strong background in full-stack development.\nMy focus is on creating efficient, secure, and scalable solutions that solve real-world problems.',
        skills: [
            'Component Design Patterns',
            'State Management Strategies',
            'Responsive Design Systems',
            'Accessibility (WCAG)',
            'Cloud Infrastructure (AWS)'
        ]
    });
    const [loading, setLoading] = useState(true);
    const [isEditing, setIsEditing] = useState(false);
    const [editForm, setEditForm] = useState(aboutData);

    useEffect(() => {
        const aboutRef = ref(db, 'profile/about');
        onValue(aboutRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                setAboutData(data);
                setEditForm(data);
            }
            setLoading(false);
        });
    }, []);

    const handleEditToggle = () => {
        if (!isEditing) {
            setEditForm(aboutData);
        }
        setIsEditing(!isEditing);
    };

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setEditForm(prev => ({ ...prev, [name]: value }));
    };

    const handleSkillsChange = (e) => {
        const skillsArray = e.target.value.split('\n').filter(skill => skill.trim() !== '');
        setEditForm(prev => ({ ...prev, skills: skillsArray }));
    };

    const handleSave = async () => {
        try {
            await set(ref(db, 'profile/about'), editForm);
            alert('Profile updated successfully!');
            setIsEditing(false);
        } catch (error) {
            console.error("Error updating profile: ", error);
            alert('Failed to update profile.');
        }
    };

    if (loading) {
        return <div className="loading-spinner">Loading...</div>;
    }

    return (
        <motion.div
            className="page-container about-page"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
        >
            <div className="edit-controls" style={{ position: 'absolute', top: '100px', right: '20px', zIndex: 10 }}>
                {isEditing ? (
                    <div style={{ display: 'flex', gap: '10px' }}>
                        <button onClick={handleSave} className="btn btn-primary" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            <Save size={16} /> Save
                        </button>
                        <button onClick={handleEditToggle} className="btn btn-secondary" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                            <X size={16} /> Cancel
                        </button>
                    </div>
                ) : (
                    <button onClick={handleEditToggle} className="btn btn-primary" style={{ padding: '0.5rem 1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <Edit2 size={16} /> Edit Profile
                    </button>
                )}
            </div>

            <header className="page-header">
                {isEditing ? (
                    <div className="edit-form-group" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem', width: '100%' }}>
                        <input
                            name="title"
                            value={editForm.title}
                            onChange={handleInputChange}
                            className="edit-input-large"
                            style={{ fontSize: '2.5rem', textAlign: 'center', width: '100%', maxWidth: '600px' }}
                        />
                        <input
                            name="subtitle"
                            value={editForm.subtitle}
                            onChange={handleInputChange}
                            className="edit-input"
                            style={{ fontSize: '1.1rem', textAlign: 'center', width: '100%', maxWidth: '600px' }}
                        />
                    </div>
                ) : (
                    <>
                        <h1>{aboutData.title}</h1>
                        <p>{aboutData.subtitle}</p>
                    </>
                )}
            </header>

            <div className="about-content">
                <section className="about-section">
                    <h2>My Journey</h2>
                    {isEditing ? (
                        <textarea
                            name="bio"
                            value={editForm.bio}
                            onChange={handleInputChange}
                            className="edit-textarea"
                            rows={6}
                        />
                    ) : (
                        <p style={{ whiteSpace: 'pre-line' }}>{aboutData.bio}</p>
                    )}
                </section>

                <section className="about-section">
                    <h2>Technical Expertise</h2>
                    {isEditing ? (
                        <div className="skills-edit">
                            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                                Enter one skill per line:
                            </label>
                            <textarea
                                value={editForm.skills ? editForm.skills.join('\n') : ''}
                                onChange={handleSkillsChange}
                                className="edit-textarea"
                                rows={8}
                            />
                        </div>
                    ) : (
                        <ul>
                            {aboutData.skills && aboutData.skills.map((skill, index) => (
                                <li key={index}>{skill}</li>
                            ))}
                        </ul>
                    )}
                </section>
            </div>
        </motion.div>
    );
};

export default About;
