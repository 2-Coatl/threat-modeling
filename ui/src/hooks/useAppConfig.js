import { useSelector } from 'react-redux';

import { selectAppConfig } from '@state/slices/appConfigSlice';

const useAppConfig = () => useSelector(selectAppConfig);

export default useAppConfig;
