import { Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import '../styles/projects.css';
import { ArrowRight, Plus, X, Trash2 } from 'lucide-react';
import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { ref, onValue, push, remove } from 'firebase/database';

const Projects = () => {
    const [projectsData, setProjectsData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        techStack: '',
        repoLink: '',
        demoLink: '',
        features: '',
        architecture: '',
        challenges: '',
        learnings: ''
    });

    useEffect(() => {
        const projectsRef = ref(db, 'projects');
        onValue(projectsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const loadedProjects = Object.keys(data).map(key => ({
                    id: key,
                    ...data[key]
                }));
                // Reverse to show newest first
                setProjectsData(loadedProjects.reverse());
            } else {
                setProjectsData([]);
            }
            setLoading(false);
        });
    }, []);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const newProject = {
                ...formData,
                techStack: formData.techStack.split(',').map(item => item.trim()),
                features: formData.features.split('\n').filter(item => item.trim() !== ''),
                timestamp: Date.now()
            };

            await push(ref(db, 'projects'), newProject);

            alert('Project added successfully!');
            setIsFormOpen(false);
            setFormData({
                title: '', description: '', techStack: '', repoLink: '',
                demoLink: '', features: '', architecture: '', challenges: '', learnings: ''
            });
        } catch (error) {
            console.error("Error adding project: ", error);
            alert("Failed to add project");
        }
    };

    const handleDelete = async (id, e) => {
        e.preventDefault();
        e.stopPropagation();
        if (window.confirm("Are you sure you want to delete this project?")) {
            try {
                await remove(ref(db, `projects/${id}`));
            } catch (error) {
                console.error("Error deleting project:", error);
                alert("Failed to delete project.");
            }
        }
    };

    if (loading) {
        return (
            <div className="page-container projects-page" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
                <div className="loading-spinner">Loading Projects...</div>
            </div>
        );
    }

    return (
        <motion.div
            className="page-container projects-page"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
        >
            <header className="page-header" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem' }}>
                <h1>Selected Works</h1>
                <p>A collection of robust, scalable applications.</p>
                <button className="btn btn-primary" onClick={() => setIsFormOpen(true)}>
                    <Plus size={18} /> Add New Project
                </button>
            </header>

            <AnimatePresence>
                {isFormOpen && (
                    <motion.div
                        className="modal-overlay"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                    >
                        <div className="modal-content">
                            <div className="modal-header">
                                <h2>Add New Project</h2>
                                <button className="close-btn" onClick={() => setIsFormOpen(false)}><X size={24} /></button>
                            </div>
                            <form onSubmit={handleSubmit} className="project-form">
                                <input required name="title" placeholder="Project Title" value={formData.title} onChange={handleInputChange} />
                                <input required name="description" placeholder="Brief Description" value={formData.description} onChange={handleInputChange} />
                                <input required name="techStack" placeholder="Tech Stack (comma separated)" value={formData.techStack} onChange={handleInputChange} />
                                <div className="form-row">
                                    <input name="repoLink" placeholder="GitHub Link" value={formData.repoLink} onChange={handleInputChange} />
                                    <input name="demoLink" placeholder="Live Demo Link" value={formData.demoLink} onChange={handleInputChange} />
                                </div>
                                <textarea name="features" placeholder="Features (one per line)" value={formData.features} onChange={handleInputChange} />
                                <textarea name="architecture" placeholder="Architecture details" value={formData.architecture} onChange={handleInputChange} />
                                <textarea name="challenges" placeholder="Challenges & Solutions" value={formData.challenges} onChange={handleInputChange} />
                                <textarea name="learnings" placeholder="Key Learnings" value={formData.learnings} onChange={handleInputChange} />

                                <button type="submit" className="btn btn-primary">Publish Project</button>
                            </form>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>

            {projectsData.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>
                    No projects found. Click "Add New Project" to get started.
                </div>
            ) : (
                <div className="projects-grid">
                    {projectsData.map((project) => (
                        <motion.article
                            key={project.id}
                            className="project-card"
                            layoutId={`project-${project.id}`}
                            initial={{ opacity: 0, y: 20 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.3 }}
                        >
                            <div className="card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', width: '100%' }}>
                                <h3>{project.title}</h3>
                                <button
                                    onClick={(e) => handleDelete(project.id, e)}
                                    className="delete-btn"
                                    title="Delete Project"
                                    style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', padding: '5px' }}
                                >
                                    <Trash2 size={18} />
                                </button>
                            </div>
                            <div className="card-content">
                                <p>{project.description}</p>
                                <div className="card-tags">
                                    {project.techStack && project.techStack.slice(0, 3).map((tech, i) => (
                                        <span key={i} className="tag">{tech}</span>
                                    ))}
                                </div>
                                <Link to={`/projects/${project.id}`} className="card-link">
                                    View Details <ArrowRight size={16} />
                                </Link>
                            </div>
                        </motion.article>
                    ))}
                </div>
            )}
        </motion.div>
    );
};

export default Projects;
