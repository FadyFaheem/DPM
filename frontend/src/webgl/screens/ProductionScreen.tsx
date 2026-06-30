import { useState } from 'react';
import type { ReactNode } from 'react';
import { Container, Text } from '@react-three/uikit';
import { Button, Card, Progress } from '@react-three/uikit-default';
import { buildProduction, upgradeProduction } from '../../api/production';
import { buildStructure } from '../../api/structures';
import { buildAttraction, upgradeAttraction } from '../../api/attractions';
import { useWebgl } from '../WebglState';
import { BRAND_COLORS } from '../../theme/theme';
import ScreenScaffold from '../ui/ScreenScaffold';

function storeLabel(column: string | null): string {
  return column ? column.replace('food_', '') : '';
}

// WebGL Food Production screen: build/upgrade farms, build facilities, and
// build/upgrade attractions for passive income.
export default function ProductionScreen() {
  const { game } = useWebgl();
  const player = game.player;
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  if (!player) return null;
  const { buildings, catalog } = player.food_productions;
  const advancedUnlocked = player.research.unlocked.includes('advanced_farming');
  const facilities = player.structures?.catalog ?? [];
  const attractionsBuilt = player.attractions?.built ?? [];
  const attractionCatalog = player.attractions?.catalog ?? [];
  const builtAttractionKinds = new Set(attractionsBuilt.map((a) => a.kind));
  const passiveIncome = attractionsBuilt.reduce((sum, a) => sum + a.income_per_day, 0);

  const run = async (key: string, action: () => Promise<unknown>) => {
    setBusy(key);
    setError(null);
    try {
      await action();
      await game.refresh();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(null);
    }
  };

  return (
    <ScreenScaffold title="Food Production">
      {error != null && (
        <Text fontSize={13} color="#d32f2f">
          {error}
        </Text>
      )}

      <SectionTitle>Build farms</SectionTitle>
      <Row>
        {catalog.map((entry) => (
          <InfoCard
            key={entry.kind}
            title={entry.name}
            cost={entry.build_cost}
            lines={[`+${entry.base_output_per_day}/day ${storeLabel(entry.food_column)}`]}
            warn={entry.unlocked ? null : `Requires: ${entry.required_tech}`}
            actionLabel="Build"
            disabled={!entry.unlocked || player.currency < entry.build_cost || busy === `b-${entry.kind}`}
            onAction={() => run(`b-${entry.kind}`, () => buildProduction(entry.kind))}
          />
        ))}
      </Row>

      <SectionTitle>Your farms</SectionTitle>
      {buildings.length === 0 && (
        <Text fontSize={13} color={BRAND_COLORS.mediumGray}>
          No farms yet. Build one above.
        </Text>
      )}
      <Row>
        {buildings.map((building) => {
          const preyPct = building.prey_capacity
            ? Math.round((building.prey_population / building.prey_capacity) * 100)
            : 0;
          return (
            <Card key={building.id} flexDirection="column" gap={5} padding={14} width={230}>
              <Container flexDirection="row" justifyContent="space-between" alignItems="center">
                <Text fontSize={15} fontWeight="bold">
                  {building.name}
                </Text>
                <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
                  Lvl {building.level}
                </Text>
              </Container>
              <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
                +{building.output_per_day}/day {storeLabel(building.food_column)}
              </Text>
              {building.prey && (
                <Container flexDirection="column" gap={2}>
                  <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
                    Prey {building.prey_population}/{building.prey_capacity}
                  </Text>
                  <Progress value={Math.min(100, preyPct)} width="100%" />
                </Container>
              )}
              <Button
                variant="outline"
                size="sm"
                disabled={!advancedUnlocked || busy === `u-${building.id}`}
                onClick={() => run(`u-${building.id}`, () => upgradeProduction(building.id))}
              >
                <Text>{advancedUnlocked ? 'Upgrade' : 'Needs Advanced Farming'}</Text>
              </Button>
            </Card>
          );
        })}
      </Row>

      <SectionTitle>Facilities</SectionTitle>
      <Row>
        {facilities.map((facility) => (
          <InfoCard
            key={facility.kind}
            title={facility.name}
            cost={facility.cost}
            lines={[]}
            warn={facility.unlocked ? null : `Requires: ${facility.required_tech}`}
            actionLabel={facility.built ? 'Built' : 'Build'}
            disabled={
              facility.built ||
              !facility.unlocked ||
              player.currency < facility.cost ||
              busy === `f-${facility.kind}`
            }
            onAction={() => run(`f-${facility.kind}`, () => buildStructure(facility.kind))}
          />
        ))}
      </Row>

      <Container flexDirection="row" gap={10} alignItems="baseline">
        <SectionTitle>Attractions</SectionTitle>
        {passiveIncome > 0 && (
          <Text fontSize={12} color={BRAND_COLORS.mediumGray}>
            Passive income: +{passiveIncome.toLocaleString()}/day
          </Text>
        )}
      </Container>
      <Row>
        {attractionCatalog.map((entry) => (
          <InfoCard
            key={entry.kind}
            title={entry.name}
            cost={entry.build_cost}
            lines={[`+${entry.income_per_day.toLocaleString()}/day currency`]}
            warn={entry.unlocked ? null : `Requires: ${entry.required_tech}`}
            actionLabel={builtAttractionKinds.has(entry.kind) ? 'Built' : 'Build'}
            disabled={
              builtAttractionKinds.has(entry.kind) ||
              !entry.unlocked ||
              player.currency < entry.build_cost ||
              busy === `a-${entry.kind}`
            }
            onAction={() => run(`a-${entry.kind}`, () => buildAttraction(entry.kind))}
          />
        ))}
      </Row>
      {attractionsBuilt.length > 0 && (
        <Row>
          {attractionsBuilt.map((attraction) => (
            <Card key={attraction.id} flexDirection="column" gap={5} padding={14} width={230}>
              <Container flexDirection="row" justifyContent="space-between" alignItems="center">
                <Text fontSize={15} fontWeight="bold">
                  {attraction.name}
                </Text>
                <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
                  Lvl {attraction.level}
                </Text>
              </Container>
              <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
                +{attraction.income_per_day.toLocaleString()}/day currency
              </Text>
              <Button
                variant="outline"
                size="sm"
                disabled={busy === `au-${attraction.id}`}
                onClick={() => run(`au-${attraction.id}`, () => upgradeAttraction(attraction.id))}
              >
                <Text>Upgrade</Text>
              </Button>
            </Card>
          ))}
        </Row>
      )}
    </ScreenScaffold>
  );
}

function SectionTitle({ children }: { children: string }) {
  return (
    <Text fontSize={16} fontWeight="bold">
      {children}
    </Text>
  );
}

function Row({ children }: { children: ReactNode }) {
  return (
    <Container flexDirection="row" gap={12} flexWrap="wrap">
      {children}
    </Container>
  );
}

function InfoCard({
  title,
  cost,
  lines,
  warn,
  actionLabel,
  disabled,
  onAction,
}: {
  title: string;
  cost: number;
  lines: string[];
  warn: string | null;
  actionLabel: string;
  disabled: boolean;
  onAction: () => void;
}) {
  return (
    <Card flexDirection="column" gap={5} padding={14} width={230}>
      <Container flexDirection="row" justifyContent="space-between" alignItems="center">
        <Text fontSize={15} fontWeight="bold">
          {title}
        </Text>
        <Text fontSize={11} color={BRAND_COLORS.mediumGray}>
          {cost.toLocaleString()}
        </Text>
      </Container>
      {lines.map((l, i) => (
        <Text key={i} fontSize={11} color={BRAND_COLORS.mediumGray}>
          {l}
        </Text>
      ))}
      {warn != null && (
        <Text fontSize={11} color="#ed6c02">
          {warn}
        </Text>
      )}
      <Button variant="default" size="sm" disabled={disabled} onClick={onAction}>
        <Text>{actionLabel}</Text>
      </Button>
    </Card>
  );
}
