import React from 'react';
import { GroupProps } from '@react-three/fiber';
import VirtualTurntable from './VirtualTurntable';
import VirtualMixer from './VirtualMixer';

interface DJBoothProps extends GroupProps {
    position: [number, number, number];
}

const DJBooth: React.FC<DJBoothProps> = ({ position, ...props }) => {
    return (
        <group position={position} {...props}>
            {/* Booth platform */}
            <mesh>
                <boxGeometry args={[6, 0.2, 3]} />
                <meshStandardMaterial color="#333" />
            </mesh>

            {/* DJ Equipment */}
            <VirtualTurntable position={[-1.5, 0.8, 0]} />
            <VirtualTurntable position={[1.5, 0.8, 0]} />
            <VirtualMixer position={[0, 0.8, 0]} />

            {/* Equipment rack */}
            <mesh position={[0, 1.5, -1]}>
                <boxGeometry args={[4, 1, 0.5]} />
                <meshStandardMaterial color="#222" />
            </mesh>

            {/* DJ Booth walls */}
            <mesh position={[-3, 1, 0]}>
                <boxGeometry args={[0.2, 2, 3]} />
                <meshStandardMaterial color="#444" />
            </mesh>
            <mesh position={[3, 1, 0]}>
                <boxGeometry args={[0.2, 2, 3]} />
                <meshStandardMaterial color="#444" />
            </mesh>
        </group>
    );
};

export default DJBooth;

