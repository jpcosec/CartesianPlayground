# Problems Directory

This directory contains problem definitions for CartesianPlayground's educational activities.

## Structure

```
problems/
├── plot_points/      # Point plotting problems
├── distance/         # Distance calculation problems
├── slope/            # Slope calculation problems
├── lessons/          # Problem collections (lessons)
└── README.md         # This file
```

## Adding New Problems

Teachers can add new problems by creating JSON files in the appropriate subdirectory.

### Example Problem File

Create a file like `plot_points/my_problem.json`:

```json
{
  "id": "my_custom_001",
  "type": "plot_points",
  "difficulty": 1,
  "title": {
    "en": "My Custom Problem",
    "es": "Mi Problema Personalizado"
  },
  "instructions": {
    "en": "Plot the point (5, 7).",
    "es": "Grafica el punto (5, 7)."
  },
  "validation": {
    "type": "point_at_coordinates",
    "expected": {"x": 5, "y": 7},
    "tolerance": 0.5
  }
}
```

### Problem Types

- **plot_points**: Student places a point at specified coordinates
- **measure_distance**: Student calculates distance between two points
- **find_slope**: Student calculates slope of a line
- **draw_line_with_slope**: Student creates a line with specific properties
- **check_colinearity**: Student determines if points are colinear
- **find_equation**: Student finds the equation of a line

## See Full Documentation

For complete instructions on creating problems, see:
`docs/TEACHER_GUIDE.md`
