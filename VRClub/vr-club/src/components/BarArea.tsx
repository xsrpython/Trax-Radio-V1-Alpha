import React from 'react';
import { GroupProps } from '@react-three/fiber';

interface BarAreaProps extends GroupProps {
    position: [number, number, number];
}

const BarArea: React.FC<BarAreaProps> = ({ position, ...props }) => {
    return (
        <group position={position} {...props}>
            {/* Bar counter */}
            <mesh>
                <boxGeometry args={[4, 1, 0.5]} />
                <meshStandardMaterial color="#654321" />
            </mesh>

            {/* Bar stools */}
            <mesh position={[1.5, 0.3, 1]}>
                <cylinderGeometry args={[0.2, 0.2, 0.6, 16]} />
                <meshStandardMaterial color="#8B4513" />
            </mesh>
            <mesh position={[-1.5, 0.3, 1]}>
                <cylinderGeometry args={[0.2, 0.2, 0.6, 16]} />
                <meshStandardMaterial color="#8B4513" />
            </mesh>

            {/* Bar lighting */}
            <pointLight position={[0, 2, 0]} intensity={0.5} color="#ffaa00" />
        </group>
    );
};

export default BarArea;

