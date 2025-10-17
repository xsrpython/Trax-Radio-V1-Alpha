import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { GroupProps } from '@react-three/fiber';
import * as THREE from 'three';

interface DanceFloorProps extends GroupProps {
    position: [number, number, number];
}

const DanceFloor: React.FC<DanceFloorProps> = ({ position, ...props }) => {
    const floorRef = useRef<THREE.Mesh>(null);

    useFrame((state) => {
        // Animate dance floor based on simulated beat
        if (floorRef.current) {
            const time = state.clock.getElapsedTime();
            const beat = Math.sin(time * 2) * 0.5 + 0.5;

            floorRef.current.material.emissiveIntensity = beat * 0.5;
            floorRef.current.material.emissive.setHSL(beat * 0.3, 1, 0.3);
        }
    });

    return (
        <group position={position} {...props}>
            {/* Main dance floor */}
            <mesh ref={floorRef}>
                <planeGeometry args={[20, 20]} />
                <meshStandardMaterial
                    color="#1a1a1a"
                    emissive="#0000ff"
                    emissiveIntensity={0.2}
                />
            </mesh>

            {/* Dance floor border */}
            <mesh position={[0, 0.01, 0]}>
                <ringGeometry args={[10, 10.2, 64]} />
                <meshStandardMaterial color="#333" />
            </mesh>
        </group>
    );
};

export default DanceFloor;

