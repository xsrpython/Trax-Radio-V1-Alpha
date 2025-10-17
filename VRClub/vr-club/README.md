# Club Nations - Virtual Reality Club Experience

This project is a browser-based Virtual Reality (VR) club experience, built using React, Three.js (via React-Three-Fiber), and WebXR. The goal is to create an immersive environment where users can socialize, experience music, and eventually watch live DJ performances.

## 🚀 Quick Start

Follow these steps to get your development environment set up and run Club Nations locally.

### Prerequisites

- Node.js (LTS version recommended)
- npm (comes with Node.js)

### Installation

1. **Clone the repository (or navigate to your project directory):**
   ```bash
   cd C:\Users\xsr_p\Desktop\VRClub\vr-club
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```
   This will install all necessary React, Three.js, and WebXR related packages.

### Running the Application

To start the development server and open Club Nations in your browser:

```bash
npm start
```

This command runs the app in development mode. Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload if you make edits. You will also see any lint errors in the console.

## ✨ Features

### Virtual Environment
- **Club Floor**: A large, dark club floor with reflective properties.
- **DJ Booth**: An elevated stage with virtual turntables and a mixer.
- **Dance Floor**: A central area with beat-reactive lighting.
- **Bar Areas**: Designated bar counters with stools.
- **VIP Areas**: Elevated sections with railings.
- **Dynamic Lighting**: Beat-reactive point light that changes intensity and color.

### Technical
- **React-Three-Fiber**: Declarative 3D scenes with React components.
- **WebXR Support**: Ready for VR headsets (click the VR button).
- **OrbitControls**: Mouse/keyboard navigation for desktop users.
- **TypeScript**: For type-safe development.
- **Modular Components**: Easy to extend and modify.

## 🎮 How to Use

### Desktop
- **Navigate**: Use your mouse to orbit around the scene.
- **Zoom**: Scroll your mouse wheel to zoom in and out.

### VR Headset (WebXR compatible)
1. Ensure your VR headset is connected and configured for WebXR.
2. Open the application in a WebXR-enabled browser (e.g., Oculus Browser, Chrome).
3. Click the "Enter VR" button that appears on the screen.

## 🛣️ Next Steps

- **Music System**: Implement pre-recorded music playback, audio visualization, and beat detection.
- **Avatar System**: Develop customizable user avatars with dance animations.
- **Social Features**: Add chat, friend systems, and audience interaction.
- **Live Streaming**: Integrate WebRTC for live DJ audio and video streaming.
- **DDJ-1000 Integration**: Map MIDI controls from physical DJ equipment to virtual functions.

---

**Project Status**: Phase 1 (Basic 3D Environment) - Complete! 🎉
**Club Nations**: Where Virtual Reality Meets Nightlife