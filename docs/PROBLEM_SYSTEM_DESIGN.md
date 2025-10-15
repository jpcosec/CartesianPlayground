# Problem System Design - Teacher-Friendly Problem Creation

## Overview

This document describes the problem creation system for CartesianPlayground that allows **teachers to create math problems WITHOUT coding**.

## Goals

1. **No Coding Required**: Teachers define problems in simple text files (JSON format)
2. **Flexible**: Support multiple problem types (plotting, distance, slope, etc.)
3. **Multilingual**: Support Spanish, English, and other languages
4. **Gradable**: Automatic validation of student answers
5. **Progressive**: Problems can have hints, multiple parts, difficulty levels

---

## Problem Definition Format

### Location
```
love2d/problems/
├── plot_points/
│   ├── problem_001.json
│   ├── problem_002.json
│   └── ...
├── distance/
│   ├── problem_001.json
│   └── ...
└── slope/
    └── ...
```

### Problem JSON Structure

```json
{
  "id": "plot_001",
  "type": "plot_points",
  "difficulty": 1,
  "title": {
    "en": "Plot a Point",
    "es": "Graficar un Punto"
  },
  "instructions": {
    "en": "Plot the point (3, 5) on the grid.",
    "es": "Grafica el punto (3, 5) en la cuadrícula."
  },
  "hints": [
    {
      "en": "Remember: (x, y) means go x units right and y units up.",
      "es": "Recuerda: (x, y) significa ir x unidades a la derecha y y unidades arriba."
    }
  ],
  "validation": {
    "type": "point_at_coordinates",
    "expected": {
      "x": 3,
      "y": 5
    },
    "tolerance": 0.5
  },
  "success_message": {
    "en": "Correct! You plotted (3, 5) perfectly.",
    "es": "¡Correcto! Graficaste (3, 5) perfectamente."
  }
}
```

---

## Supported Problem Types

### 1. Plot Points
**Teacher Creates:**
```json
{
  "type": "plot_points",
  "validation": {
    "type": "point_at_coordinates",
    "expected": {"x": 3, "y": -2}
  }
}
```

**Student Does:** Clicks to place a point at (3, -2)

---

### 2. Measure Distance
**Teacher Creates:**
```json
{
  "type": "measure_distance",
  "setup": {
    "point1": {"x": 2, "y": 3},
    "point2": {"x": 5, "y": 7}
  },
  "validation": {
    "type": "numeric_answer",
    "expected": 5.0,
    "tolerance": 0.1
  }
}
```

**Student Does:** Calculates distance using formula or measuring tool

---

### 3. Find Slope
**Teacher Creates:**
```json
{
  "type": "find_slope",
  "setup": {
    "line": {
      "point1": {"x": 1, "y": 2},
      "point2": {"x": 4, "y": 8}
    }
  },
  "validation": {
    "type": "numeric_answer",
    "expected": 2.0,
    "tolerance": 0.01
  }
}
```

**Student Does:** Calculates slope (rise over run)

---

### 4. Draw Line with Given Slope
**Teacher Creates:**
```json
{
  "type": "draw_line_with_slope",
  "instructions": {
    "en": "Draw a line with slope 2 passing through (1, 1)"
  },
  "validation": {
    "type": "line_properties",
    "expected": {
      "slope": 2.0,
      "passes_through": {"x": 1, "y": 1}
    },
    "tolerance": 0.1
  }
}
```

**Student Does:** Creates a line and adjusts its slope

---

### 5. Check Colinearity
**Teacher Creates:**
```json
{
  "type": "check_colinearity",
  "setup": {
    "points": [
      {"x": 1, "y": 2},
      {"x": 2, "y": 4},
      {"x": 3, "y": 6}
    ]
  },
  "validation": {
    "type": "boolean_answer",
    "expected": true
  }
}
```

**Student Does:** Determines if points are on the same line

---

### 6. Find Equation
**Teacher Creates:**
```json
{
  "type": "find_equation",
  "setup": {
    "line_through_points": {
      "point1": {"x": 0, "y": 2},
      "point2": {"x": 2, "y": 6}
    }
  },
  "validation": {
    "type": "equation",
    "expected": {
      "slope": 2,
      "y_intercept": 2
    },
    "tolerance": 0.01
  }
}
```

**Student Does:** Writes equation in form y = mx + b

---

## Problem Collections (Lessons)

Teachers can group problems into lessons:

```json
{
  "lesson_id": "intro_to_plotting",
  "title": {
    "en": "Introduction to Plotting Points",
    "es": "Introducción a Graficar Puntos"
  },
  "description": {
    "en": "Learn how to plot points on the Cartesian plane.",
    "es": "Aprende a graficar puntos en el plano cartesiano."
  },
  "problems": [
    "plot_001",
    "plot_002",
    "plot_003",
    "plot_004",
    "plot_005"
  ],
  "required_score": 0.8
}
```

---

## Validation System

### Validation Types

1. **point_at_coordinates**: Check if student placed point at (x, y)
2. **numeric_answer**: Check if numeric input matches expected value
3. **boolean_answer**: Check yes/no or true/false answer
4. **line_properties**: Check slope, y-intercept, passes through point
5. **equation**: Parse and validate mathematical equation
6. **multiple_points**: Check multiple points are correctly placed

### Tolerance System

All numeric validations support tolerance:
```json
"validation": {
  "expected": 5.0,
  "tolerance": 0.1  // Accepts 4.9 to 5.1
}
```

---

## Teacher Workflow

### Step 1: Choose Problem Type
Teacher decides: "I want students to practice finding distance"

### Step 2: Create JSON File
```bash
love2d/problems/distance/problem_my_custom_001.json
```

### Step 3: Fill in the Template
```json
{
  "type": "measure_distance",
  "title": {"en": "Distance Practice"},
  "instructions": {"en": "Find the distance between the two points."},
  "setup": {
    "point1": {"x": 0, "y": 0},
    "point2": {"x": 3, "y": 4}
  },
  "validation": {
    "type": "numeric_answer",
    "expected": 5.0,
    "tolerance": 0.1
  }
}
```

### Step 4: Test in Application
- Run the app
- Select "Problems" mode
- Choose their custom problem
- Verify it works correctly

### Step 5: Share
- Share JSON file with other teachers
- Students load problem from file

---

## Implementation Architecture

### File Structure
```
love2d/
├── activities/
│   ├── activity_base.lua         # Base class for all activities
│   ├── plot_points_activity.lua  # Handles plotting problems
│   ├── distance_activity.lua     # Handles distance problems
│   ├── slope_activity.lua        # Handles slope problems
│   └── ...
├── problems/
│   ├── plot_points/
│   ├── distance/
│   ├── slope/
│   └── lessons/
├── lib/
│   ├── geometry.lua              # Math utilities
│   ├── problem_loader.lua        # Load/parse JSON problems
│   └── validator.lua             # Validate student answers
└── i18n/
    ├── en.lua                    # English translations
    └── es.lua                    # Spanish translations
```

### Code Flow

```
1. Student clicks "Problems" button
   ↓
2. App shows list of lessons/problems
   ↓
3. Student selects a problem
   ↓
4. problem_loader.lua reads JSON file
   ↓
5. App creates appropriate activity instance
   ↓
6. Student interacts with problem
   ↓
7. validator.lua checks answer
   ↓
8. App shows feedback (correct/incorrect + hints)
```

---

## Future Enhancements

### Phase 2: Problem Editor GUI
- In-app problem creation tool
- Visual problem builder
- No JSON editing required

### Phase 3: Problem Sharing Platform
- Online repository of problems
- Rating and reviews
- Search by topic/difficulty

### Phase 4: Analytics
- Track student performance
- Identify common mistakes
- Adaptive difficulty

---

## Example: Complete Problem Set

A teacher creates a lesson "Introduction to Slope":

```
love2d/problems/lessons/intro_to_slope.json
```

```json
{
  "lesson_id": "intro_slope_001",
  "title": {
    "en": "Introduction to Slope",
    "es": "Introducción a la Pendiente"
  },
  "problems": [
    {
      "id": "slope_positive",
      "type": "find_slope",
      "instructions": {
        "en": "Calculate the slope of the line through (1, 2) and (3, 6)."
      },
      "setup": {
        "line": {
          "point1": {"x": 1, "y": 2},
          "point2": {"x": 3, "y": 6}
        }
      },
      "validation": {
        "type": "numeric_answer",
        "expected": 2.0,
        "tolerance": 0.01
      }
    },
    {
      "id": "slope_negative",
      "type": "find_slope",
      "instructions": {
        "en": "Calculate the slope of the line through (0, 4) and (2, 0)."
      },
      "setup": {
        "line": {
          "point1": {"x": 0, "y": 4},
          "point2": {"x": 2, "y": 0}
        }
      },
      "validation": {
        "type": "numeric_answer",
        "expected": -2.0,
        "tolerance": 0.01
      }
    }
  ]
}
```

Students work through problems sequentially, getting immediate feedback.

---

## Summary

This system allows teachers to:
- ✅ Create problems in simple JSON files (no coding!)
- ✅ Support multiple languages
- ✅ Define validation rules
- ✅ Provide hints and feedback
- ✅ Organize problems into lessons
- ✅ Share problems with other teachers

The system is:
- **Flexible**: New problem types can be added
- **Extensible**: Teachers can create unlimited problems
- **Educational**: Immediate feedback helps learning
- **Accessible**: Works in multiple languages
