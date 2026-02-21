import { useForm } from '../hooks/useForm';
import { Mail, Linkedin, Github, Send } from 'lucide-react';
import { db } from '../config/firebase';
import { ref, push } from 'firebase/database';
import '../styles/contact.css';

const Contact = () => {

    const validate = (values) => {
        let errors = {};
        if (!values.name) errors.name = 'Name is required';
        if (!values.email) {
            errors.email = 'Email is required';
        } else if (!/\S+@\S+\.\S+/.test(values.email)) {
            errors.email = 'Email address is invalid';
        }
        if (!values.message) errors.message = 'Message is required';
        return errors;
    };

    const submitForm = async () => {
        try {
            const messagesRef = ref(db, 'contact_messages');
            await push(messagesRef, {
                ...values,
                timestamp: Date.now(),
                date: new Date().toISOString()
            });
            alert('Message sent successfully!');
        } catch (error) {
            console.error("Error sending message: ", error);
            alert('Failed to send message. Please try again.');
        }
    };

    const { values, errors, isSubmitting, handleChange, handleSubmit } = useForm(
        { name: '', email: '', message: '' },
        validate
    );

    return (
        <div className="page-container contact-page page-transition">
            <header className="page-header animate-slide-up">
                <h1>Get In Touch</h1>
                <p>Interested in collaborating? Let&apos;s connect.</p>
            </header>

            <div className="contact-content animate-slide-up delay-100">
                <div className="contact-info">
                    <h3>Contact Information</h3>
                    <p>Feel free to reach out for collaborations or just a friendly hello.</p>

                    <div className="contact-links">
                        <a href="https://mail.google.com/mail/?view=cm&fs=1&to=venkatmallacs@gmail.com" target="_blank" rel="noopener noreferrer" className="contact-item animate-fade-in delay-200">
                            <Mail size={20} /> venkatmallacs@gmail.com
                        </a>
                        <a href="https://www.linkedin.com/in/venkat-malla-5528b8381" target="_blank" rel="noopener noreferrer" className="contact-item animate-fade-in delay-300">
                            <Linkedin size={20} /> LinkedIn Profile
                        </a>
                        <a href="https://github.com/venkatmalla6" target="_blank" rel="noopener noreferrer" className="contact-item animate-fade-in delay-400">
                            <Github size={20} /> GitHub Profile
                        </a>
                    </div>
                </div>

                <form className="contact-form animate-slide-up delay-200" onSubmit={(e) => { e.preventDefault(); handleSubmit(submitForm); }}>
                    <div className="form-group">
                        <label htmlFor="name">Name</label>
                        <input
                            type="text"
                            id="name"
                            name="name"
                            value={values.name}
                            onChange={handleChange}
                            className={errors.name ? 'error' : ''}
                            placeholder="Your Name"
                        />
                        {errors.name && <span className="error-text">{errors.name}</span>}
                    </div>

                    <div className="form-group">
                        <label htmlFor="email">Email</label>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            value={values.email}
                            onChange={handleChange}
                            className={errors.email ? 'error' : ''}
                            placeholder="your.email@example.com"
                        />
                        {errors.email && <span className="error-text">{errors.email}</span>}
                    </div>

                    <div className="form-group">
                        <label htmlFor="message">Message</label>
                        <textarea
                            id="message"
                            name="message"
                            rows="5"
                            value={values.message}
                            onChange={handleChange}
                            className={errors.message ? 'error' : ''}
                            placeholder="How can I help you?"
                        ></textarea>
                        {errors.message && <span className="error-text">{errors.message}</span>}
                    </div>

                    <button type="submit" className="btn btn-primary submit-btn" disabled={isSubmitting}>
                        {isSubmitting ? 'Sending...' : <>Send Message <Send size={18} /></>}
                    </button>
                </form>
            </div>
        </div>
    );
};

export default Contact;
