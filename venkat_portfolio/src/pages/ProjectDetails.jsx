import { useParams, Navigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowLeft, ExternalLink, Github } from 'lucide-react';
import '../styles/projects.css';
import { useState, useEffect } from 'react';
import { db } from '../config/firebase';
import { ref, get } from 'firebase/database';

const ProjectDetails = () => {
    const { id } = useParams();
    const [project, setProject] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(false);

    useEffect(() => {
        const fetchProject = async () => {
            try {
                const projectRef = ref(db, `projects/${id}`);
                const snapshot = await get(projectRef);
                if (snapshot.exists()) {
                    setProject(snapshot.val());
                } else {
                    setError(true);
                }
            } catch (err) {
                console.error("Error fetching project details:", err);
                setError(true);
            } finally {
                setLoading(false);
            }
        };

        fetchProject();
    }, [id]);

    if (loading) {
        return (
            <div className="page-container project-details" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
                <div className="loading-spinner">Loading Details...</div>
            </div>
        );
    }

    if (error || !project) {
        return <Navigate to="/projects" replace />;
    }

    return (
        <motion.div
            className="page-container project-details"
            layoutId={`project-${id}`}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
        >
            <Link to="/projects" className="back-link">
                <ArrowLeft size={20} /> Back to Projects
            </Link>

            <header className="details-header">
                <h1>{project.title}</h1>
                <div className="details-actions">
                    {project.repoLink && (
                        <a href={project.repoLink} className="btn btn-secondary" target="_blank" rel="noreferrer">
                            <Github size={18} /> Code
                        </a>
                    )}
                    {project.demoLink && (
                        <a href={project.demoLink} className="btn btn-primary" target="_blank" rel="noreferrer">
                            <ExternalLink size={18} /> Live Demo
                        </a>
                    )}
                </div>
            </header>

            <section className="details-section">
                <h2>Overview</h2>
                <p>{project.description}</p>

                <h3>Tech Stack</h3>
                <div className="tech-tags">
                    {project.techStack && project.techStack.map(tech => (
                        <span key={tech} className="tech-badge">{tech}</span>
                    ))}
                </div>
            </section>

            <div className="details-grid">
                {project.features && (
                    <section className="details-section">
                        <h2>Key Features</h2>
                        <ul>
                            {project.features.map((feature, index) => (
                                <li key={index}>{feature}</li>
                            ))}
                        </ul>
                    </section>
                )}

                {project.architecture && (
                    <section className="details-section">
                        <h2>Architecture</h2>
                        <p>{project.architecture}</p>
                    </section>
                )}

                {project.challenges && (
                    <section className="details-section">
                        <h2>Challenges & Solutions</h2>
                        <p>{project.challenges}</p>
                    </section>
                )}

                {project.learnings && (
                    <section className="details-section">
                        <h2>Learnings</h2>
                        <p>{project.learnings}</p>
                    </section>
                )}
            </div>
        </motion.div>
    );
};

export default ProjectDetails;
