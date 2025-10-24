import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  productName: 'Threat Modeling Workbench',
  tagline: 'Centralized workflows with modular experiences.'
};

const appConfigSlice = createSlice({
  name: 'appConfig',
  initialState,
  reducers: {
    setProductName(state, action) {
      state.productName = action.payload;
    },
    setTagline(state, action) {
      state.tagline = action.payload;
    }
  }
});

export const { setProductName, setTagline } = appConfigSlice.actions;
export const selectAppConfig = (state) => state.appConfig;

export default appConfigSlice.reducer;
