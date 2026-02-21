import { Link, NavLink } from 'react-router-dom';
import { useTheme } from '../context/ThemeContext';
import '../styles/layout.css';
import { Sun, Moon, Menu, X } from 'lucide-react';
import { useState } from 'react';

const Navbar = () => {
    const { theme, toggleTheme } = useTheme();
    const [isOpen, setIsOpen] = useState(false);

    const toggleMenu = () => setIsOpen(!isOpen);

    const navLinks = [
        { name: 'Home', path: '/' },
        { name: 'About', path: '/about' },
        { name: 'Work', path: '/projects' },
        { name: 'Blog', path: '/blog' },
        { name: 'Contact', path: '/contact' },
    ];

    return (
        <nav className="navbar">
            <div className="nav-container">
                <Link to="/" className="nav-logo">
                    <div className="logo-container">
                        <span>MV</span>
                    </div>
                </Link>

                <div className={`nav-links ${isOpen ? 'active' : ''}`}>
                    {navLinks.map((link) => (
                        <NavLink
                            key={link.name}
                            to={link.path}
                            className={({ isActive }) => isActive ? 'nav-item active' : 'nav-item'}
                            onClick={() => setIsOpen(false)}
                        >
                            {link.name}
                        </NavLink>
                    ))}
                </div>

                <div className="nav-actions">
                    <Link to="/contact" className="btn btn-primary hire-me-btn">
                        Hire Me
                    </Link>
                    <button onClick={toggleTheme} className="theme-toggle" aria-label="Toggle Theme">
                        {theme === 'light' ? <Moon size={20} /> : <Sun size={20} />}
                    </button>

                    <button className="mobile-menu-btn" onClick={toggleMenu} aria-label="Toggle Menu">
                        {isOpen ? <X size={24} /> : <Menu size={24} />}
                    </button>
                </div>
            </div>
        </nav>
    );

};

export default Navbar;
