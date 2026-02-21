import { Link, useNavigate } from 'react-router-dom';
import { Upload, ArrowRight, Users, Briefcase } from 'lucide-react';
import '../styles/home.css';
import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { ref, onValue, set, update } from 'firebase/database';
import EditableText from '../components/EditableText';
import EditableImage from '../components/EditableImage';

const Home = () => {
    const [resumeUrl, setResumeUrl] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [projects, setProjects] = useState([]);
    const [content, setContent] = useState(() => {
        const cachedImage = localStorage.getItem('hero_image');
        console.log("[Home] Initializing state. Cached image found:", !!cachedImage);
        return {
            hero: {
                greeting: "Hi, I'm Malla Venkat",
                title: "Creative Developer & DevOps Engineer",
                description: "I design and build robust digital products that make people's lives easier. Specializing in Cloud Infrastructure, Docker, and Kubernetes.",
                image: cachedImage || null
            },
            about: {
                text: "I'm a passionate DevOps Engineer and Full Stack Developer with experience in designing scalable cloud architectures and building user-friendly applications. I thrive on solving complex problems and delivering high-quality solutions."
            },
            stats: [
                { id: 0, number: "50+", label: "Projects Completed" },
                { id: 1, number: "150%", label: "Performance Boost" },
                { id: 2, number: "98%", label: "Client Satisfaction" }
            ]
        };
    });

    const navigate = useNavigate();

    // Firebase Logic
    useEffect(() => {
        // Fetch Resume URL
        const resumeRef = ref(db, 'profile/resumeUrl');
        onValue(resumeRef, (snapshot) => {
            const data = snapshot.val();
            if (data) setResumeUrl(data);
        });

        // Fetch Page Content
        const contentRef = ref(db, 'content/home');
        onValue(contentRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                if (data.hero && data.hero.image) {
                    console.log("[Home] Updating cache with new image from DB");
                    localStorage.setItem('hero_image', data.hero.image);
                }
                setContent(prev => ({
                    ...prev,
                    hero: { ...prev.hero, ...data.hero },
                    about: { ...prev.about, ...data.about },
                    stats: data.stats || prev.stats
                }));
            }
        });

        // Fetch Projects
        const projectsRef = ref(db, 'projects');
        onValue(projectsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const loadedProjects = Object.keys(data).map(key => ({
                    id: key,
                    ...data[key]
                }));
                setProjects(loadedProjects.reverse()); // Show newest first
            }
        });
    }, []);

    const handleUploadResume = async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        if (file.size > 2 * 1024 * 1024) {
            alert("File is too large. Please upload a resume smaller than 2MB.");
            return;
        }

        setUploading(true);
        const reader = new FileReader();
        reader.onloadend = async () => {
            try {
                await set(ref(db, 'profile/resumeUrl'), reader.result);
                alert('Resume uploaded successfully!');
            } catch (error) {
                alert('Failed to save resume: ' + error.message);
            } finally {
                setUploading(false);
            }
        };
        reader.readAsDataURL(file);
    };

    const handleSaveContent = (section, key, value) => {
        const path = `content/home/${section}/${key}`;
        update(ref(db), { [path]: value })
            .catch(err => {
                console.error("Error updating content:", err);
                alert("Failed to save changes to database: " + err.message);
            });

        // Optimistic update
        setContent(prev => ({
            ...prev,
            [section]: {
                ...prev[section],
                [key]: value
            }
        }));
    };

    const handleSaveStat = (index, key, value) => {
        const updatedStats = [...content.stats];
        updatedStats[index] = { ...updatedStats[index], [key]: value };

        update(ref(db), { 'content/home/stats': updatedStats })
            .catch(err => console.error("Error updating stats:", err));

        setContent(prev => ({ ...prev, stats: updatedStats }));
    };

    const scrollToSection = (id) => {
        const element = document.getElementById(id);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth' });
        }
    };

    return (
        <div className="home-container">
            {/* Hero Section */}
            <section className="hero-section">
                <div className="hero-grid">
                    <div className="hero-content animate-slide-up">
                        <EditableText
                            tagName="span"
                            className="greeting"
                            initialValue={content.hero.greeting}
                            onSave={(val) => handleSaveContent('hero', 'greeting', val)}
                        />

                        <div className="hero-title-container">
                            <EditableText
                                tagName="h1"
                                className="hero-title"
                                initialValue={content.hero.title}
                                onSave={(val) => handleSaveContent('hero', 'title', val)}
                                multiline
                            />
                        </div>

                        <EditableText
                            tagName="p"
                            className="hero-description"
                            initialValue={content.hero.description}
                            onSave={(val) => handleSaveContent('hero', 'description', val)}
                            multiline
                        />

                        <div className="cta-group">
                            <Link to="/contact" className="btn btn-primary">Hire Me</Link>
                            <button onClick={() => scrollToSection('work')} className="btn btn-secondary">
                                View Portfolio
                            </button>
                        </div>

                        {/* Resume Actions */}
                        <div className="resume-actions">
                            {resumeUrl ? (
                                <button onClick={() => navigate('/resume')} className="text-link">
                                    View My Resume
                                </button>
                            ) : (
                                <button onClick={() => document.getElementById('resume-upload').click()} className="text-link" disabled={uploading}>
                                    {uploading ? 'Uploading...' : 'Upload Resume'}
                                </button>
                            )}
                            <input type="file" id="resume-upload" style={{ display: 'none' }} accept="application/pdf" onChange={handleUploadResume} />
                        </div>

                        <div className="client-logos">
                            {/* Static logos for now */}
                            <div className="logo-circle"><img src="https://upload.wikimedia.org/wikipedia/commons/a/a7/React-icon.svg" alt="React" /></div>
                            <div className="logo-circle"><img src="https://www.vectorlogo.zone/logos/amazon_aws/amazon_aws-icon.svg" alt="AWS" /></div>
                            <div className="logo-circle"><img src="https://www.vectorlogo.zone/logos/docker/docker-icon.svg" alt="Docker" /></div>
                            <div className="logo-circle"><img src="https://www.vectorlogo.zone/logos/linux/linux-icon.svg" alt="Linux" /></div>
                        </div>
                    </div>

                    <div className="hero-image-container animate-fade-in">
                        <div className="abstract-blob blob-1"></div>
                        <div className="abstract-blob blob-2"></div>

                        <EditableImage
                            src={content.hero.image}
                            onSave={(url) => handleSaveContent('hero', 'image', url)}
                            onDelete={() => handleSaveContent('hero', 'image', null)}
                            className="hero-profile-img"
                            alt="Profile"
                            storagePath="profile"
                        />
                    </div>
                </div>
            </section>

            {/* About Section */}
            <section className="about-section" id="about">
                <div className="section-header">
                    <div className="icon-box"><Users size={24} /></div>
                    <h2>About Me</h2>
                </div>

                <div className="about-content">
                    <EditableText
                        tagName="p"
                        className="about-text"
                        initialValue={content.about.text}
                        onSave={(val) => handleSaveContent('about', 'text', val)}
                        multiline
                    />

                    <div className="stats-grid">
                        {content.stats.map((stat, index) => (
                            <div key={index} className="stat-card">
                                <EditableText
                                    tagName="h3"
                                    initialValue={stat.number}
                                    onSave={(val) => handleSaveStat(index, 'number', val)}
                                />
                                <EditableText
                                    tagName="p"
                                    initialValue={stat.label}
                                    onSave={(val) => handleSaveStat(index, 'label', val)}
                                />
                            </div>
                        ))}
                    </div>
                </div>
            </section>

            {/* My Work Section */}
            <section className="work-section" id="work">
                <div className="section-header">
                    <div className="icon-box"><Briefcase size={24} /></div>
                    <h2>My Work</h2>
                </div>

                <div className="projects-grid-home">
                    {projects.length > 0 ? (
                        projects.slice(0, 3).map((project) => (
                            <div key={project.id} className="project-card-home">
                                <div className="card-image">
                                    <img src={project.image || "https://placehold.co/600x400?text=No+Image"} alt={project.title} />
                                </div>
                                <div className="card-body">
                                    <h3>{project.title}</h3>
                                    <p>{project.description.substring(0, 100)}...</p>
                                    <Link to={`/projects/${project.id}`} className="btn btn-primary small-btn">
                                        View Project
                                    </Link>
                                </div>
                            </div>
                        ))
                    ) : (
                        <div style={{ gridColumn: '1/-1', textAlign: 'center', color: '#666' }}>
                            <p>No projects added yet.</p>
                            <Link to="/projects" className="btn btn-secondary" style={{ marginTop: '1rem' }}>
                                Add Your First Project
                            </Link>
                        </div>
                    )}
                </div>

                <div className="view-all-container">
                    <Link to="/projects" className="btn btn-outline">View All Projects <ArrowRight size={16} /></Link>
                </div>
            </section>
        </div>
    );
};

export default Home;
