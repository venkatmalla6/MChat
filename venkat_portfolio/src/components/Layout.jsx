import Navbar from './Navbar';
import Footer from './Footer';
import PropTypes from 'prop-types';

const Layout = ({ children }) => {
    return (
        <div className="app-layout">
            <Navbar />
            <main className="main-content">
                {children}
            </main>
            <Footer />
        </div>
    );
};

Layout.propTypes = {
    children: PropTypes.node.isRequired,
};

export default Layout;
