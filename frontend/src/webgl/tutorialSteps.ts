import type { ScreenId } from './screensConfig';

export interface TutorialStep {
  screen: ScreenId;
  title: string;
  body: string;
}

// Guided tour that walks the player through every screen. Each step navigates to
// its screen so the player sees it while reading.
export const TUTORIAL_STEPS: TutorialStep[] = [
  {
    screen: 'park',
    title: 'Welcome to your park',
    body: 'This is your 3D park. Dinosaurs roam their habitats - drag to orbit, scroll to zoom, and hold right-click to pan around. Click any dinosaur to feed, move, treat, or quarantine it. Population and average health are shown top-left.',
  },
  {
    screen: 'habitats',
    title: 'Habitats',
    body: 'Build habitats across terrains (forest, grassland, wetland, volcanic, aquatic) and upgrade them to raise capacity for more dinosaurs.',
  },
  {
    screen: 'species',
    title: 'Species',
    body: 'Acquire new dinosaur species across the Triassic, Jurassic, and Cretaceous. Some need research or a larger park before you can bring them in.',
  },
  {
    screen: 'research',
    title: 'Research',
    body: 'Unlock technologies to expand your park and enable food production, attractions, and stronger genetics.',
  },
  {
    screen: 'production',
    title: 'Production',
    body: 'Build farms to grow food, plus facilities and attractions that generate passive income every game-day.',
  },
  {
    screen: 'goals',
    title: 'Goals & Prestige',
    body: 'Complete goals for currency rewards, and build a legendary park to win - then prestige to start New Game+ with a permanent income bonus.',
  },
  {
    screen: 'profile',
    title: 'Profile',
    body: 'Your park code lets you log in on another device - keep it safe. You can also load another park by entering its code.',
  },
  {
    screen: 'park',
    title: "You're all set!",
    body: 'That is the tour. Replay it anytime with the Tutorial button on the Park screen. Have fun building your park!',
  },
];

export const TUTORIAL_SEEN_KEY = 'dpm_tutorial_done';
