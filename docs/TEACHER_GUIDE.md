# Teacher Guide - Creating Problems for CartesianPlayground

## Welcome!

This guide will show you how to create your own math problems for CartesianPlayground **without writing any code**. All you need to do is create simple text files in JSON format.

---

## Quick Start

### Step 1: Choose Where to Put Your Problem

Navigate to the `love2d/problems/` folder and choose a subfolder:
- `plot_points/` - For problems about plotting coordinates
- `distance/` - For distance calculation problems
- `slope/` - For slope calculation problems

### Step 2: Create a New File

Create a new file with a `.json` extension. For example:
```
plot_points/my_first_problem.json
```

### Step 3: Copy a Template

Use one of the templates below based on your problem type.

### Step 4: Edit the File

Fill in the blanks with your problem details.

### Step 5: Test It

Run the application and select "Problems" mode to test your problem.

---

## Problem Templates

### Template 1: Plot a Point

**File**: `plot_points/my_problem.json`

```json
{
  "id": "my_unique_id",
  "type": "plot_points",
  "difficulty": 1,
  "title": {
    "en": "Your Title Here",
    "es": "Tu Título Aquí"
  },
  "instructions": {
    "en": "Plot the point (X, Y) on the grid.",
    "es": "Grafica el punto (X, Y) en la cuadrícula."
  },
  "hints": [
    {
      "en": "First hint in English",
      "es": "Primera pista en español"
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
    "en": "Correct!",
    "es": "¡Correcto!"
  }
}
```

**What to change:**
- `id`: Make it unique (e.g., "plot_mary_001")
- `title`: Your problem title
- `instructions`: Tell students what to do
- `hints`: Optional help messages
- `expected.x` and `expected.y`: The correct coordinates
- `tolerance`: How close the student must be (0.5 = half a grid square)

---

### Template 2: Calculate Distance

**File**: `distance/my_problem.json`

```json
{
  "id": "distance_my_001",
  "type": "measure_distance",
  "difficulty": 1,
  "title": {
    "en": "Find the Distance",
    "es": "Halla la Distancia"
  },
  "instructions": {
    "en": "Calculate the distance between (2, 3) and (5, 7).",
    "es": "Calcula la distancia entre (2, 3) y (5, 7)."
  },
  "setup": {
    "point1": {"x": 2, "y": 3},
    "point2": {"x": 5, "y": 7}
  },
  "hints": [
    {
      "en": "Use the distance formula: d = √[(x₂-x₁)² + (y₂-y₁)²]",
      "es": "Usa la fórmula: d = √[(x₂-x₁)² + (y₂-y₁)²]"
    }
  ],
  "validation": {
    "type": "numeric_answer",
    "expected": 5.0,
    "tolerance": 0.1
  }
}
```

**What to change:**
- `setup.point1` and `setup.point2`: The two points
- `validation.expected`: The correct answer (calculate it first!)
- `tolerance`: How close is acceptable (0.1 = ±0.1 units)

**How to calculate the answer:**
1. Use calculator: √[(x₂-x₁)² + (y₂-y₁)²]
2. For example: √[(5-2)² + (7-3)²] = √[9 + 16] = √25 = 5.0

---

### Template 3: Find Slope

**File**: `slope/my_problem.json`

```json
{
  "id": "slope_my_001",
  "type": "find_slope",
  "difficulty": 1,
  "title": {
    "en": "Calculate the Slope",
    "es": "Calcula la Pendiente"
  },
  "instructions": {
    "en": "Find the slope of the line through (1, 2) and (3, 6).",
    "es": "Halla la pendiente de la línea por (1, 2) y (3, 6)."
  },
  "setup": {
    "line": {
      "point1": {"x": 1, "y": 2},
      "point2": {"x": 3, "y": 6}
    }
  },
  "hints": [
    {
      "en": "Formula: m = (y₂ - y₁) / (x₂ - x₁)",
      "es": "Fórmula: m = (y₂ - y₁) / (x₂ - x₁)"
    }
  ],
  "validation": {
    "type": "numeric_answer",
    "expected": 2.0,
    "tolerance": 0.01
  }
}
```

**How to calculate slope:**
- Slope = (y₂ - y₁) / (x₂ - x₁)
- Example: (6 - 2) / (3 - 1) = 4 / 2 = 2.0

---

## Field Reference

### Required Fields

Every problem must have:

| Field | Description | Example |
|-------|-------------|---------|
| `id` | Unique identifier | `"plot_001"` |
| `type` | Problem type | `"plot_points"` |
| `difficulty` | 1 (easy), 2 (medium), 3 (hard) | `1` |
| `title` | Problem title in English and Spanish | `{"en": "Title", "es": "Título"}` |
| `instructions` | What student should do | `{"en": "Plot...", "es": "Grafica..."}` |
| `validation` | How to check the answer | See validation types below |

### Optional Fields

| Field | Description |
|-------|-------------|
| `hints` | Array of helpful hints |
| `success_message` | Custom message when correct |
| `setup` | Initial configuration (points, lines, etc.) |

---

## Validation Types

### 1. Point at Coordinates

```json
"validation": {
  "type": "point_at_coordinates",
  "expected": {"x": 3, "y": 5},
  "tolerance": 0.5
}
```

- Student must place a point near the expected coordinates
- `tolerance`: Maximum distance allowed (in grid units)

### 2. Numeric Answer

```json
"validation": {
  "type": "numeric_answer",
  "expected": 5.0,
  "tolerance": 0.1
}
```

- Student must enter a number
- `expected`: The correct answer
- `tolerance`: Acceptable margin of error

### 3. Boolean Answer

```json
"validation": {
  "type": "boolean_answer",
  "expected": true
}
```

- Student must answer yes/no or true/false
- `expected`: `true` or `false`

---

## Tips for Creating Good Problems

### 1. Start Simple

Begin with easy problems and gradually increase difficulty.

**Easy**: Plot (2, 3)
**Medium**: Plot (-4, 5)
**Hard**: Plot (-7, -3)

### 2. Use Realistic Numbers

Avoid decimals in early problems. Use integers students can easily work with.

**Good**: Distance from (0, 0) to (3, 4) = 5
**Too Hard**: Distance from (1.5, 2.7) to (4.8, 6.2)

### 3. Provide Helpful Hints

Give hints that help students remember formulas or strategies.

```json
"hints": [
  {
    "en": "Positive x means go right from the origin.",
    "es": "X positivo significa ir a la derecha desde el origen."
  }
]
```

### 4. Test Your Problems

Always test your problems before sharing them with students!

### 5. Set Appropriate Tolerance

- For point placement: `0.5` (half a grid square)
- For distance: `0.1` (within 0.1 units)
- For slope: `0.01` (very precise)

---

## Creating a Lesson

Group multiple problems into a lesson:

**File**: `lessons/my_lesson.json`

```json
{
  "lesson_id": "my_first_lesson",
  "title": {
    "en": "Introduction to Quadrants",
    "es": "Introducción a los Cuadrantes"
  },
  "description": {
    "en": "Learn to plot points in all four quadrants.",
    "es": "Aprende a graficar puntos en los cuatro cuadrantes."
  },
  "problems": [
    "plot_001",
    "plot_002",
    "plot_003"
  ],
  "required_score": 0.8
}
```

- `problems`: List of problem IDs (in order)
- `required_score`: Percentage needed to pass (0.8 = 80%)

---

## Common Mistakes

### ❌ Forgetting Commas

```json
{
  "id": "test"
  "type": "plot_points"  ← MISSING COMMA!
}
```

**Fix:** Add comma after `"test"`

### ❌ Wrong Quote Marks

```json
"title": {
  'en': 'Title'  ← WRONG! Use double quotes
}
```

**Fix:** Always use `"` not `'`

### ❌ Missing Curly Braces

```json
"expected":
  "x": 3,
  "y": 5  ← MISSING { }
```

**Fix:** Wrap in braces: `{"x": 3, "y": 5}`

---

## Testing Your JSON

Before using your problem in the app, you can test if your JSON is valid:

1. Visit: https://jsonlint.com/
2. Paste your JSON code
3. Click "Validate JSON"
4. Fix any errors it reports

---

## Example: Complete Problem

Here's a complete, working example:

```json
{
  "id": "plot_quadrant_2",
  "type": "plot_points",
  "difficulty": 2,
  "title": {
    "en": "Plotting in Quadrant II",
    "es": "Graficar en el Cuadrante II"
  },
  "instructions": {
    "en": "Plot the point (-5, 3) on the grid. This point is in Quadrant II.",
    "es": "Grafica el punto (-5, 3) en la cuadrícula. Este punto está en el Cuadrante II."
  },
  "hints": [
    {
      "en": "In Quadrant II, x is negative and y is positive.",
      "es": "En el Cuadrante II, x es negativo y y es positivo."
    },
    {
      "en": "Start at the origin, then move 5 units left and 3 units up.",
      "es": "Comienza en el origen, luego muévete 5 unidades a la izquierda y 3 arriba."
    }
  ],
  "validation": {
    "type": "point_at_coordinates",
    "expected": {
      "x": -5,
      "y": 3
    },
    "tolerance": 0.5
  },
  "success_message": {
    "en": "Perfect! You plotted (-5, 3) correctly in Quadrant II!",
    "es": "¡Perfecto! ¡Graficaste (-5, 3) correctamente en el Cuadrante II!"
  }
}
```

---

## Getting Help

If you have questions:

1. Look at the example problems in `love2d/problems/`
2. Check the `PROBLEM_SYSTEM_DESIGN.md` for technical details
3. Ask a colleague who has created problems before

---

## Sharing Your Problems

Once you've created and tested your problems:

1. **Share the JSON files** with other teachers
2. **Document any special instructions** for your problems
3. **Include answer keys** in a separate document

---

## Summary Checklist

When creating a problem:

- [ ] Choose appropriate problem type
- [ ] Give it a unique ID
- [ ] Write clear instructions in both languages
- [ ] Calculate the correct answer
- [ ] Set reasonable tolerance
- [ ] Add helpful hints
- [ ] Test the JSON for errors
- [ ] Test the problem in the app
- [ ] Verify the answer validation works

---

**Happy Problem Creating!** 🎓
