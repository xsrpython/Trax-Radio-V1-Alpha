import React from 'react';
import { XR } from '@react-three/xr';
import ClubFloor from './ClubFloor';
import DJBooth from './DJBooth';
import DanceFloor from './DanceFloor';
import BarArea from './BarArea';
import VIPArea from './VIPArea';
import BeatReactiveLighting from './BeatReactiveLighting';

const ClubNations: React.FC = () => {
    return (
        <XR>
            {/* Club floor */}
            <ClubFloor />

            {/* DJ Booth */}
            <DJBooth position={[0, 1.5, -10]} />

            {/* Dance floor */}
            <DanceFloor position={[0, 0, 0]} />

            {/* Bar areas */}
            <BarArea position={[-8, 0, -8]} />
            <BarArea position={[8, 0, -8]} />

            {/* VIP areas */}
            <VIPArea position={[-6, 1, -5]} />
            <VIPArea position={[6, 1, -5]} />

            {/* Beat-reactive lighting */}
            <BeatReactiveLighting />
        </XR>
    );
};

export default ClubNations;

