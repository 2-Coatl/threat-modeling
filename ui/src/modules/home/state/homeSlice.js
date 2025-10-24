import { createSlice } from '@reduxjs/toolkit';

const announcements = [
  'Plan collaboratively across teams with a shared threat backlog.',
  'Map mitigations to findings to close audit gaps faster.',
  'Centralize risk evidence so stakeholders stay aligned.'
];

const initialState = {
  announcements,
  activeIndex: 0
};

const homeSlice = createSlice({
  name: 'home',
  initialState,
  reducers: {
    rotateAnnouncement(state) {
      if (state.announcements.length === 0) {
        return;
      }

      state.activeIndex = (state.activeIndex + 1) % state.announcements.length;
    },
    setAnnouncements(state, action) {
      state.announcements = action.payload;
      state.activeIndex = 0;
    }
  }
});

export const { rotateAnnouncement, setAnnouncements } = homeSlice.actions;

export const selectHomeAnnouncement = (state) => {
  const { announcements: messageList, activeIndex } = state.home;
  return messageList[activeIndex] ?? '';
};

export default homeSlice.reducer;
