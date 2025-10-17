import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import * as THREE from 'three';

const BeatReactiveLighting: React.FC = () => {
    const mainLightRef = useRef<THREE.PointLight>(null);
    const leftLightRef = useRef<THREE.PointLight>(null);
    const rightLightRef = useRef<THREE.PointLight>(null);

    useFrame((state) => {
        const time = state.clock.getElapsedTime();

        // Simulate beat detection
        const beat = Math.sin(time * 2) * 0.5 + 0.5;
        const bass = Math.sin(time * 1.5) * 0.5 + 0.5;

        // Update lighting intensity and color
        if (mainLightRef.current) {
            mainLightRef.current.intensity = 1 + beat * 2;
            mainLightRef.current.color.setHSL(beat * 0.3, 1, 0.5);
        }

        if (leftLightRef.current) {
            leftLightRef.current.intensity = 0.5 + bass * 1;
            leftLightRef.current.color.setHSL(0.7 + bass * 0.2, 1, 0.5);
        }

        if (rightLightRef.current) {
            rightLightRef.current.intensity = 0.5 + bass * 1;
            rightLightRef.current.color.setHSL(0.1 + bass * 0.2, 1, 0.5);
        }
    });

    return (
        <>
            {/* Main club lighting */}
            <pointLight
                ref={mainLightRef}
                position={[0, 8, 0]}
                intensity={1}
                color="#ffffff"
            />

            {/* Left side lighting */}
            <pointLight
                ref={leftLightRef}
                position={[-8, 6, 0]}
                intensity={0.5}
                color="#ff0000"
            />

            {/* Right side lighting */}
            <pointLight
                ref={rightLightRef}
                position={[8, 6, 0]}
                intensity={0.5}
                color="#0000ff"
            />
        </>
    );
};

export default BeatReactiveLighting;

