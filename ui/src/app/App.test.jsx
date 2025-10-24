import React from 'react';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import { render, screen, fireEvent } from '@testing-library/react';

import App from './App';
import appConfigReducer from '@state/slices/appConfigSlice';
import { homeReducer } from '@modules/home';

const renderWithStore = () => {
  const store = configureStore({
    reducer: {
      appConfig: appConfigReducer,
      home: homeReducer
    }
  });

  const view = render(
    <Provider store={store}>
      <App />
    </Provider>
  );

  return { ...view, store };
};

describe('App integration', () => {
  it('renders the layout and home module content from the store', () => {
    const { store } = renderWithStore();

    expect(screen.getByRole('heading', { level: 1 })).toHaveTextContent('Threat Modeling Platform');
    expect(screen.getByRole('heading', { level: 2 })).toHaveTextContent(
      store.getState().appConfig.productName
    );
    expect(screen.getByText(store.getState().appConfig.tagline)).toBeInTheDocument();

    const announcement = screen.getByTestId('home-announcement');
    expect(announcement).toHaveTextContent(store.getState().home.announcements[0]);

    const cta = screen.getByRole('button', { name: /next insight/i });
    fireEvent.click(cta);

    const updatedState = store.getState().home;
    expect(updatedState.activeIndex).toBe(1);
    expect(announcement).toHaveTextContent(updatedState.announcements[updatedState.activeIndex]);
  });
});
