import React from 'react';

const MainLayout = ({ children }) => (
  <div className="app-shell">
    <header className="app-shell__header">
      <h1>Threat Modeling Platform</h1>
      <p className="app-shell__subtitle">Modular monolith UI</p>
    </header>
    <main className="app-shell__content">{children}</main>
    <footer className="app-shell__footer">&copy; {new Date().getFullYear()} Secure Systems Lab</footer>
  </div>
);

export default MainLayout;
