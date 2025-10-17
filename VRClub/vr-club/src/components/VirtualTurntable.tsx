import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { GroupProps } from '@react-three/fiber';

interface VirtualTurntableProps extends GroupProps {
    position: [number, number, number];
}

const VirtualTurntable: React.FC<VirtualTurntableProps> = ({ position, ...props }) => {
    const platterRef = useRef<THREE.Mesh>(null);

    useFrame((state) => {
        // Rotate the platter continuously
        if (platterRef.current) {
            platterRef.current.rotation.y += 0.01;
        }
    });

    return (
        <group position={position} {...props}>
            {/* Turntable base */}
            <mesh>
                <cylinderGeometry args={[1, 1, 0.2, 32]} />
                <meshStandardMaterial color="#333" />
            </mesh>

            {/* Platter */}
            <mesh ref={platterRef}>
                <cylinderGeometry args={[0.9, 0.9, 0.05, 32]} />
                <meshStandardMaterial color="#222" />
            </mesh>

            {/* Center spindle */}
            <mesh position={[0, 0.03, 0]}>
                <cylinderGeometry args={[0.05, 0.05, 0.1, 16]} />
                <meshStandardMaterial color="#666" />
            </mesh>

            {/* Tone arm */}
            <mesh position={[0.6, 0.15, 0]} rotation={[0, 0, -0.3]}>
                <boxGeometry args={[0.8, 0.02, 0.02]} />
                <meshStandardMaterial color="#555" />
            </mesh>
        </group>
    );
};

export default VirtualTurntable;

