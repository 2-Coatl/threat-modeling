import React from 'react';

import useAppConfig from '@hooks/useAppConfig';

const HomePage = () => {
  const { productName, tagline } = useAppConfig();

  return (
    <section className="home-page">
      <h2>{productName}</h2>
      <p>{tagline}</p>
    </section>
  );
};

export default HomePage;
