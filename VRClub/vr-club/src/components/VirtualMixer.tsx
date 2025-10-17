import React from 'react';
import { GroupProps } from '@react-three/fiber';

interface VirtualMixerProps extends GroupProps {
    position: [number, number, number];
}

const VirtualMixer: React.FC<VirtualMixerProps> = ({ position, ...props }) => {
    return (
        <group position={position} {...props}>
            {/* Mixer base */}
            <mesh>
                <boxGeometry args={[2, 0.3, 1]} />
                <meshStandardMaterial color="#333" />
            </mesh>

            {/* Crossfader */}
            <mesh position={[0, 0.2, 0]}>
                <boxGeometry args={[0.8, 0.05, 0.05]} />
                <meshStandardMaterial color="#444" />
            </mesh>

            {/* Channel faders */}
            <mesh position={[-0.6, 0.15, 0]}>
                <boxGeometry args={[0.05, 0.3, 0.05]} />
                <meshStandardMaterial color="#555" />
            </mesh>
            <mesh position={[0.6, 0.15, 0]}>
                <boxGeometry args={[0.05, 0.3, 0.05]} />
                <meshStandardMaterial color="#555" />
            </mesh>

            {/* EQ knobs */}
            <mesh position={[-0.8, 0.15, 0]}>
                <cylinderGeometry args={[0.08, 0.08, 0.05, 16]} />
                <meshStandardMaterial color="#666" />
            </mesh>
            <mesh position={[0.8, 0.15, 0]}>
                <cylinderGeometry args={[0.08, 0.08, 0.05, 16]} />
                <meshStandardMaterial color="#666" />
            </mesh>

            {/* Effects knobs */}
            <mesh position={[-0.4, 0.15, 0]}>
                <cylinderGeometry args={[0.06, 0.06, 0.04, 16]} />
                <meshStandardMaterial color="#777" />
            </mesh>
            <mesh position={[0.4, 0.15, 0]}>
                <cylinderGeometry args={[0.06, 0.06, 0.04, 16]} />
                <meshStandardMaterial color="#777" />
            </mesh>
        </group>
    );
};

export default VirtualMixer;

