import React from 'react';
import { X, Download } from 'lucide-react';
import '../styles/home.css'; // Re-using home.css for modal styles for now

const ResumeModal = ({ isOpen, onClose, resumeUrl }) => {
    if (!isOpen) return null;

    return (
        <div className="modal-overlay" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <div className="modal-header">
                    <h2>My Resume</h2>
                    <div className="modal-actions">
                        <a href={resumeUrl} download="Venkat_Resume.pdf" className="btn-icon" title="Download">
                            <Download size={20} />
                        </a>
                        <button className="btn-icon" onClick={onClose} title="Close">
                            <X size={20} />
                        </button>
                    </div>
                </div>
                <div className="modal-body">
                    <iframe
                        src={resumeUrl}
                        title="Resume"
                        width="100%"
                        height="100%"
                        style={{ border: 'none' }}
                    >
                    </iframe>
                </div>
            </div>
        </div>
    );
};

export default ResumeModal;
