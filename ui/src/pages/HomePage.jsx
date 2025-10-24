import React from 'react';
import PropTypes from 'prop-types';

const HomePage = ({ productName, tagline, announcement, onCycleAnnouncement }) => (
  <section className="home-page">
    <h2>{productName}</h2>
    <p>{tagline}</p>

    <aside className="home-page__insight">
      <h3>Why it matters</h3>
      <p>{announcement}</p>
      <button type="button" className="home-page__cta" onClick={onCycleAnnouncement}>
        Next insight
      </button>
    </aside>
  </section>
);

HomePage.propTypes = {
  productName: PropTypes.string.isRequired,
  tagline: PropTypes.string.isRequired,
  announcement: PropTypes.string.isRequired,
  onCycleAnnouncement: PropTypes.func.isRequired
};

export default HomePage;
