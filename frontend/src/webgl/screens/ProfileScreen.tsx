import { useState } from 'react';
import { Container, Text } from '@react-three/uikit';
import { Button, Card, Input } from '@react-three/uikit-default';
import { useWebgl } from '../WebglState';
import { useTutorial } from '../TutorialContext';
import { BRAND_COLORS } from '../../theme/theme';
import ScreenScaffold from '../ui/ScreenScaffold';

// WebGL Profile screen: show the portable park code and load another park by
// code (login).
export default function ProfileScreen() {
  const { game } = useWebgl();
  const tutorial = useTutorial();
  const player = game.player;
  const [code, setCode] = useState('');
  const [copied, setCopied] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const copyCode = async () => {
    if (!player) return;
    try {
      await navigator.clipboard.writeText(player.player_code);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      /* clipboard unavailable; ignore */
    }
  };

  const load = async () => {
    if (!code.trim()) return;
    setBusy(true);
    setError(null);
    try {
      await game.login(code.trim());
    } catch {
      setError('That code did not match any park.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <ScreenScaffold title="Profile">
      <Card flexDirection="column" gap={8} padding={16} width={420}>
        <Text fontSize={16} fontWeight="bold">
          Your park code
        </Text>
        <Text fontSize={12} color={BRAND_COLORS.mediumGray}>
          Save this code to log in on another device. Anyone with it can access your park.
        </Text>
        <Container flexDirection="row" gap={10} alignItems="center">
          <Text fontSize={18} fontWeight="bold">
            {player?.player_code ?? '...'}
          </Text>
          <Button variant="outline" size="sm" onClick={copyCode}>
            <Text>{copied ? 'Copied!' : 'Copy'}</Text>
          </Button>
        </Container>
      </Card>

      <Card flexDirection="column" gap={8} padding={16} width={420}>
        <Text fontSize={16} fontWeight="bold">
          Load a park
        </Text>
        <Text fontSize={12} color={BRAND_COLORS.mediumGray}>
          Enter a code from another device to switch to that park.
        </Text>
        <Container flexDirection="row" gap={8} alignItems="center">
          <Container flexGrow={1}>
            <Input value={code} onValueChange={setCode} placeholder="Park code" />
          </Container>
          <Button variant="default" size="sm" disabled={busy || !code.trim()} onClick={load}>
            <Text>Load</Text>
          </Button>
        </Container>
        {error != null && (
          <Text fontSize={13} color="#d32f2f">
            {error}
          </Text>
        )}
      </Card>

      <Card flexDirection="column" gap={8} padding={16} width={420}>
        <Text fontSize={16} fontWeight="bold">
          Tutorial
        </Text>
        <Text fontSize={12} color={BRAND_COLORS.mediumGray}>
          Replay the guided tour of every screen.
        </Text>
        <Container flexDirection="row">
          <Button variant="outline" size="sm" onClick={tutorial.start}>
            <Text>Replay tutorial</Text>
          </Button>
        </Container>
      </Card>
    </ScreenScaffold>
  );
}
