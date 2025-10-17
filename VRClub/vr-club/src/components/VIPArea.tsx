import React from 'react';
import { GroupProps } from '@react-three/fiber';

interface VIPAreaProps extends GroupProps {
    position: [number, number, number];
}

const VIPArea: React.FC<VIPAreaProps> = ({ position, ...props }) => {
    return (
        <group position={position} {...props}>
            {/* VIP platform */}
            <mesh>
                <boxGeometry args={[6, 0.1, 6]} />
                <meshStandardMaterial color="#2a2a2a" />
            </mesh>

            {/* VIP seating */}
            <mesh position={[0, 0.3, 0]}>
                <boxGeometry args={[4, 0.6, 0.8]} />
                <meshStandardMaterial color="#4a4a4a" />
            </mesh>

            {/* VIP table */}
            <mesh position={[0, 0.4, 2]}>
                <cylinderGeometry args={[0.5, 0.5, 0.1, 16]} />
                <meshStandardMaterial color="#654321" />
            </mesh>

            {/* VIP lighting */}
            <pointLight position={[0, 3, 0]} intensity={0.3} color="#ff00ff" />
        </group>
    );
};

export default VIPArea;

