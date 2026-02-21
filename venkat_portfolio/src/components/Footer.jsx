const Footer = () => {
    return (
        <footer className="footer">
            <div className="footer-content">
                <p>&copy; {new Date().getFullYear()} Senior Frontend Portfolio. All rights reserved.</p>
                <div className="social-links">
                    <a href="https://github.com/venkatmalla6" target="_blank" rel="noopener noreferrer">GitHub</a>
                    <a href="https://www.linkedin.com/in/venkat-malla-5528b8381" target="_blank" rel="noopener noreferrer">LinkedIn</a>
                    <a href="https://mail.google.com/mail/?view=cm&fs=1&to=venkatmallacs@gmail.com" target="_blank" rel="noopener noreferrer">venkatmallacs@gmail.com</a>
                </div>
            </div>
        </footer>
    );
};

export default Footer;
