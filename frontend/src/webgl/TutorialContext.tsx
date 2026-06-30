import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import { useWebgl } from './WebglState';
import { TUTORIAL_SEEN_KEY, TUTORIAL_STEPS, type TutorialStep } from './tutorialSteps';

interface TutorialState {
  active: boolean;
  index: number;
  total: number;
  step: TutorialStep | null;
  start: () => void;
  next: () => void;
  back: () => void;
  skip: () => void;
}

const TutorialContext = createContext<TutorialState | null>(null);

function markSeen() {
  try {
    localStorage.setItem(TUTORIAL_SEEN_KEY, '1');
  } catch {
    /* localStorage unavailable; ignore */
  }
}

// Drives the guided tour. Lives inside the canvas (uses WebglState's setScreen to
// navigate per step). Auto-starts once for players who haven't seen it; can be
// replayed via start().
export function TutorialProvider({ children }: { children: ReactNode }) {
  const { game, setScreen } = useWebgl();
  const [active, setActive] = useState(false);
  const [index, setIndex] = useState(0);
  const autostarted = useRef(false);

  const goto = useCallback(
    (i: number) => {
      setIndex(i);
      setScreen(TUTORIAL_STEPS[i].screen);
    },
    [setScreen],
  );

  const start = useCallback(() => {
    setActive(true);
    goto(0);
  }, [goto]);

  const finish = useCallback(() => {
    setActive(false);
    markSeen();
  }, []);

  const next = useCallback(() => {
    if (index >= TUTORIAL_STEPS.length - 1) finish();
    else goto(index + 1);
  }, [index, goto, finish]);

  const back = useCallback(() => {
    if (index > 0) goto(index - 1);
  }, [index, goto]);

  // Auto-start once when a player is present and the tour hasn't been seen.
  useEffect(() => {
    if (autostarted.current || !game.player) return;
    autostarted.current = true;
    let seen = false;
    try {
      seen = localStorage.getItem(TUTORIAL_SEEN_KEY) === '1';
    } catch {
      seen = false;
    }
    if (!seen) {
      // Intentional one-time auto-start when the player first loads.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      start();
    }
  }, [game.player, start]);

  const value = useMemo<TutorialState>(
    () => ({
      active,
      index,
      total: TUTORIAL_STEPS.length,
      step: active ? TUTORIAL_STEPS[index] : null,
      start,
      next,
      back,
      skip: finish,
    }),
    [active, index, start, next, back, finish],
  );

  return <TutorialContext.Provider value={value}>{children}</TutorialContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components
export function useTutorial(): TutorialState {
  const ctx = useContext(TutorialContext);
  if (!ctx) throw new Error('useTutorial must be used within a TutorialProvider');
  return ctx;
}
