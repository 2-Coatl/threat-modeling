import React from 'react';

import useAppConfig from '@hooks/useAppConfig';

import HomePage from '../../pages/HomePage';
import useHomeAnnouncement from './hooks/useHomeAnnouncement';

const HomeModule = () => {
  const { productName, tagline } = useAppConfig();
  const { announcement, cycleAnnouncement } = useHomeAnnouncement();

  return (
    <HomePage
      productName={productName}
      tagline={tagline}
      announcement={announcement}
      onCycleAnnouncement={cycleAnnouncement}
    />
  );
};

export default HomeModule;
