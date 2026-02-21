import { Suspense, lazy } from 'react';
import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import { AnimatePresence } from 'framer-motion';
import Layout from './components/Layout';
import Loading from './components/Loading';

// Lazy load pages for performance optimization
const Home = lazy(() => import('./pages/Home'));
const Projects = lazy(() => import('./pages/Projects'));
const ProjectDetails = lazy(() => import('./pages/ProjectDetails'));
const About = lazy(() => import('./pages/About'));
const Contact = lazy(() => import('./pages/Contact'));
const Blog = lazy(() => import('./pages/Blog'));
const ResumePage = lazy(() => import('./pages/ResumePage'));


function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/" element={<Home />} />
        <Route path="/projects" element={<Projects />} />
        <Route path="/projects/:id" element={<ProjectDetails />} />
        <Route path="/about" element={<About />} />
        <Route path="/blog" element={<Blog />} />
        <Route path="/contact" element={<Contact />} />

      </Routes>
    </AnimatePresence>
  );
}


import { useEffect } from 'react';
import { db } from './config/firebase';
import { ref, onValue } from 'firebase/database';

function App() {
  useEffect(() => {
    const connectedRef = ref(db, ".info/connected");
    onValue(connectedRef, (snap) => {
      if (snap.val() === true) {
        console.log("%c Firebase Connected ", "background: green; color: white; border-radius: 5px; font-weight: bold; padding: 2px 5px;");
      } else {
        console.log("%c Firebase Disconnected ", "background: red; color: white; border-radius: 5px; font-weight: bold; padding: 2px 5px;");
      }
    });
  }, []);

  return (
    <Router>
      <Suspense fallback={<Loading />}>
        <Routes>
          {/* Resume route - Standalone (No Layout) */}
          <Route path="/resume" element={<ResumePage />} />

          {/* Main App Routes - Wrapped in Layout */}
          <Route path="/*" element={
            <Layout>
              <AnimatedRoutes />
            </Layout>
          } />
        </Routes>
      </Suspense>
    </Router>
  );
}

export default App;
