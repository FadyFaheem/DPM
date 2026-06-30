import { useRef, useState } from 'react';
import { useFrame, type ThreeEvent } from '@react-three/fiber';
import { Billboard, Edges, Text } from '@react-three/drei';
import * as THREE from 'three';
import type { Habitat } from '../../api/players';
import { TILE_HEIGHT, TILE_SIZE } from '../../components/park3d/parkLayout';

interface Props {
  habitat: Habitat;
  position: [number, number];
  color: string;
  hazardColor: string;
  crowdedColor: string;
  hasHazard: boolean;
  selected: boolean;
  onSelect: (habitat: Habitat) => void;
}

// A terrain tile with WebGL (troika) text labels - no DOM. Clicking selects the
// habitat; hazard/crowding/selection show an outline.
export default function HabitatTileMesh({
  habitat,
  position,
  color,
  hazardColor,
  crowdedColor,
  hasHazard,
  selected,
  onSelect,
}: Props) {
  const mat = useRef<THREE.MeshStandardMaterial>(null);
  const [hovered, setHovered] = useState(false);
  const [x, z] = position;
  const crowded = habitat.living_count > habitat.capacity * 0.8;

  useFrame(() => {
    if (mat.current) mat.current.emissiveIntensity = hovered || selected ? 0.4 : 0;
  });

  const outlineColor = selected ? '#ffffff' : hasHazard ? hazardColor : crowdedColor;

  return (
    <group position={[x, 0, z]}>
      <mesh
        position={[0, TILE_HEIGHT / 2, 0]}
        onClick={(e: ThreeEvent<MouseEvent>) => {
          e.stopPropagation();
          onSelect(habitat);
        }}
        onPointerOver={(e: ThreeEvent<PointerEvent>) => {
          e.stopPropagation();
          setHovered(true);
          document.body.style.cursor = 'pointer';
        }}
        onPointerOut={() => {
          setHovered(false);
          document.body.style.cursor = 'auto';
        }}
      >
        <boxGeometry args={[TILE_SIZE, TILE_HEIGHT, TILE_SIZE]} />
        <meshStandardMaterial ref={mat} color={color} emissive={color} flatShading />
        {(hasHazard || crowded || selected) && (
          <Edges scale={1.02} threshold={15} color={outlineColor} />
        )}
      </mesh>

      {/* Raised above the dinos; material-depthTest off so dino bodies/health
          bars never occlude the name (it still renders below the uikit HUD,
          which draws at a higher renderOrder). */}
      <Billboard position={[0, TILE_HEIGHT + 2.4, 0]}>
        <Text
          fontSize={0.42}
          color="#ffffff"
          outlineWidth={0.03}
          outlineColor="#000000"
          anchorX="center"
          anchorY="middle"
          material-depthTest={false}
          material-depthWrite={false}
        >
          {habitat.name}
        </Text>
        <Text
          position={[0, -0.42, 0]}
          fontSize={0.28}
          color={crowded ? crowdedColor : '#e8e8e8'}
          outlineWidth={0.02}
          outlineColor="#000000"
          anchorX="center"
          anchorY="middle"
          material-depthTest={false}
          material-depthWrite={false}
        >
          {`${habitat.living_count}/${habitat.capacity}${hasHazard ? '   !' : ''}`}
        </Text>
      </Billboard>
    </group>
  );
}
