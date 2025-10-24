import { useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';

import { rotateAnnouncement, selectHomeAnnouncement } from '../state/homeSlice';

const useHomeAnnouncement = () => {
  const dispatch = useDispatch();
  const announcement = useSelector(selectHomeAnnouncement);

  const cycleAnnouncement = useCallback(() => {
    dispatch(rotateAnnouncement());
  }, [dispatch]);

  return {
    announcement,
    cycleAnnouncement
  };
};

export default useHomeAnnouncement;
