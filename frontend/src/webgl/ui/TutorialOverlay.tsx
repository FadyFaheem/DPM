import { Container, Text } from '@react-three/uikit';
import { Button, Card } from '@react-three/uikit-default';
import { useTutorial } from '../TutorialContext';
import { BRAND_COLORS } from '../../theme/theme';

// Bottom-anchored guided-tour card. Sits above every screen; the rest of the
// screen stays interactive (pointer events pass through except over the card).
export default function TutorialOverlay() {
  const tut = useTutorial();
  if (!tut.active || !tut.step) return null;
  const last = tut.index === tut.total - 1;

  return (
    <Container
      positionType="absolute"
      positionTop={0}
      positionLeft={0}
      positionRight={0}
      positionBottom={0}
      justifyContent="flex-end"
      alignItems="center"
      paddingBottom={28}
      pointerEvents="none"
      // Force the tour above every page panel so it never clips behind UI.
      zIndexOffset={1000}
      renderOrder={1000}
    >
      <Card width={540} padding={18} flexDirection="column" gap={10} pointerEvents="auto">
        <Text fontSize={18} fontWeight="bold">
          {tut.step.title}
        </Text>
        <Text fontSize={13} color={BRAND_COLORS.darkGray}>
          {tut.step.body}
        </Text>
        <Container flexDirection="row" justifyContent="space-between" alignItems="center">
          <Text fontSize={12} color={BRAND_COLORS.mediumGray}>
            Step {tut.index + 1} / {tut.total}
          </Text>
          <Container flexDirection="row" gap={6}>
            <Button variant="ghost" size="sm" onClick={tut.skip}>
              <Text>Skip</Text>
            </Button>
            <Button variant="outline" size="sm" disabled={tut.index === 0} onClick={tut.back}>
              <Text>Back</Text>
            </Button>
            <Button variant="default" size="sm" onClick={tut.next}>
              <Text>{last ? 'Done' : 'Next'}</Text>
            </Button>
          </Container>
        </Container>
      </Card>
    </Container>
  );
}
