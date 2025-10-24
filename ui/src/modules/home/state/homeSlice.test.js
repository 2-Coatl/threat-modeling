import homeReducer, { rotateAnnouncement, setAnnouncements } from './homeSlice';

const initialState = {
  announcements: [
    'Plan collaboratively across teams with a shared threat backlog.',
    'Map mitigations to findings to close audit gaps faster.',
    'Centralize risk evidence so stakeholders stay aligned.'
  ],
  activeIndex: 0
};

describe('homeSlice', () => {
  it('should return the initial state when passed an unknown action', () => {
    const nextState = homeReducer(undefined, { type: 'unknown' });
    expect(nextState).toEqual(initialState);
  });

  it('rotates announcements cyclically', () => {
    const afterFirstRotation = homeReducer(initialState, rotateAnnouncement());
    expect(afterFirstRotation.activeIndex).toBe(1);

    const afterSecondRotation = homeReducer(afterFirstRotation, rotateAnnouncement());
    expect(afterSecondRotation.activeIndex).toBe(2);

    const afterThirdRotation = homeReducer(afterSecondRotation, rotateAnnouncement());
    expect(afterThirdRotation.activeIndex).toBe(0);
  });

  it('resets the index when setting new announcements', () => {
    const workingState = {
      announcements: ['existing'],
      activeIndex: 0
    };

    const updatedState = homeReducer(workingState, setAnnouncements(['new']));
    expect(updatedState.announcements).toEqual(['new']);
    expect(updatedState.activeIndex).toBe(0);
  });
});
