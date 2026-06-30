import { describe, it, expect } from 'vitest';
import { TUTORIAL_STEPS } from '../../webgl/tutorialSteps';
import { SCREENS } from '../../webgl/screensConfig';

describe('tutorial steps', () => {
  it('covers every navigable screen', () => {
    const covered = new Set(TUTORIAL_STEPS.map((s) => s.screen));
    for (const screen of SCREENS) {
      expect(covered.has(screen.id)).toBe(true);
    }
  });

  it('has non-empty title and body for each step', () => {
    for (const step of TUTORIAL_STEPS) {
      expect(step.title.trim().length).toBeGreaterThan(0);
      expect(step.body.trim().length).toBeGreaterThan(0);
    }
  });
});
