import React from 'react';
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';

const ClubFloor: React.FC = () => {
    const floorRef = useRef<THREE.Mesh>(null);

    return (
        <mesh ref={floorRef} rotation={[-Math.PI / 2, 0, 0]}>
            <planeGeometry args={[40, 40]} />
            <meshStandardMaterial
                color="#1a1a1a"
                roughness={0.8}
                metalness={0.2}
            />
        </mesh>
    );
};

export default ClubFloor;

