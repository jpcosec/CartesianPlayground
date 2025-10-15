# Quick Start Guide

## Run LOVE2D Version (Recommended)

```bash
cd love2d
love .
```

**Requirements**: Install LOVE2D from https://love2d.org/

---

## Run Pygame Version

```bash
cd pygame
conda activate cartesian_playground
python app.py
```

**Requirements**:
- Conda environment with dependencies from `requirements.txt`
- Webcam (for face detection feature)

---

## First Time Setup

### LOVE2D
1. Download LOVE2D: https://love2d.org/
2. Install
3. Done!

### Pygame
1. Create conda environment:
   ```bash
   conda create -n cartesian_playground python=3.9
   conda activate cartesian_playground
   ```
2. Install dependencies:
   ```bash
   cd pygame
   pip install -r requirements.txt
   ```
3. Ensure `camera/haarcascade_frontalface_default.xml` exists

---

## Controls (Both Versions)

- **ESC**: Quit
- **Mouse**: Click and drag to interact
- **Buttons**: Create figures (point, line)
- **Intro**: Toggle instructions

---

## Folder Structure

```
pygame/      # Python version (full features)
love2d/      # Lua version (no camera)
docs/        # Migration guides
```

See `README.md` for full documentation.
