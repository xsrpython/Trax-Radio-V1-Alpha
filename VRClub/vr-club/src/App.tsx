import React from 'react';
import { Canvas } from '@react-three/fiber';
import { VRButton } from '@react-three/xr';
import { Environment, OrbitControls } from '@react-three/drei';
import ClubNations from './components/ClubNations';
import './App.css';

function App() {
    return (
        <div className="App">
            {/* VR Entry Button */}
            <VRButton />

            {/* 3D Club Scene */}
            <Canvas
                camera={{ position: [0, 2, 10], fov: 75 }}
                style={{ width: '100vw', height: '100vh' }}
            >
                {/* Basic lighting */}
                <ambientLight intensity={0.3} />
                <directionalLight position={[10, 10, 5]} intensity={1} />

                {/* Club environment */}
                <ClubNations />

                {/* Environment for realistic lighting */}
                <Environment preset="night" />

                {/* Camera controls for non-VR users */}
                <OrbitControls enablePan={true} enableZoom={true} enableRotate={true} />
            </Canvas>
        </div>
    );
}

export default App;
