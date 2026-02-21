export const projects = [
    {
        id: 'job-tracker',
        title: 'Job Application Tracker',
        description: 'A comprehensive dashboard to track job applications, interview statuses, and follow-ups.',
        techStack: ['React', 'Context API', 'LocalStorage', 'Chart.js'],
        features: [
            'Kanban board for application status (Applied, Interview, Offer, Rejected)',
            'Analytics dashboard showing application velocity',
            'Drag-and-drop interface',
            'Local persistence'
        ],
        challenges: 'Implementing performant drag-and-drop without external heavy libraries and managing complex state updates across columns.',
        architecture: 'Uses a centralized ApplicationContext with reducer pattern for unpredictable state transitions. Components are atomic and memoized to prevent unnecessary re-renders during drag operations.',
        learnings: 'Deepened understanding of optimistic UI updates and complex state management patterns.',
        repoLink: '#',
        demoLink: '#'
    },
    {
        id: 'expense-tracker',
        title: 'Expense Tracker with Analytics',
        description: 'Real-time expense tracking with visual data visualization and budget management.',
        techStack: ['React', 'Recharts', 'Formik', 'Yup'],
        features: [
            'Interactive charts for spending breakdown',
            'Category-wise budget setting',
            'Transaction history with filtering and sorting',
            'Export to CSV functionality'
        ],
        challenges: 'Handling large datasets of transactions and ensuring the charts render performantly on mobile devices.',
        architecture: 'Implemented a custom hook for data aggregation that processes raw transaction data into chart-friendly formats. heavy calculations are memoized.',
        learnings: 'Mastered data visualization integration and effective form validation strategies.',
        repoLink: '#',
        demoLink: '#'
    },
    {
        id: 'admin-dashboard',
        title: 'Admin Dashboard',
        description: 'A modular admin panel with role-based access control simulations and data tables.',
        techStack: ['React', 'React Router', 'TanStack Table', 'Tailwind-like Custom CSS'],
        features: [
            'Sortable and filterable data tables',
            'Role-based route protection (RBAC)',
            'Global search functionality',
            'Theme customization'
        ],
        challenges: 'Designing a flexible layout system that handles dynamic sidebar content and responsive tables simultaneously.',
        architecture: 'Composition-based layout pattern where the Sidebar and Header are decoupled from the main content area, allowing for independent scrolling and state management.',
        learnings: 'Gained expertise in building reusable compound components and implementing client-side authorization patterns.',
        repoLink: '#',
        demoLink: '#'
    }
];
