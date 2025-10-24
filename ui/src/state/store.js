import { configureStore } from '@reduxjs/toolkit';

import appConfigReducer from './slices/appConfigSlice';
import { homeReducer } from '@modules/home';

export const store = configureStore({
  reducer: {
    appConfig: appConfigReducer,
    home: homeReducer
  },
  devTools: process.env.NODE_ENV !== 'production'
});

export default store;
