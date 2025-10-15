-- i18n/es.lua
-- Spanish translations for CartesianPlayground

return {
    _language_name = "Español",
    _language_code = "es",

    -- Menu and UI
    menu = {
        title = "Patio de Juegos Cartesiano",
        sandbox_mode = "Modo Libre",
        problems_mode = "Problemas",
        settings = "Configuración",
        quit = "Salir"
    },

    -- Header buttons
    header = {
        intro = "intro",
        line = "línea",
        point = "punto",
        problems = "problemas"
    },

    -- Instructions window
    instructions = {
        title = "Instrucciones",
        welcome = "¡Bienvenido al Playground Cartesiano!",
        create_figures = "Haz clic en los botones para crear figuras geométricas:",
        point_help = "Punto: Crea un punto arrastrable",
        line_help = "Línea: Crea una línea (arrastra para ajustar pendiente, clic en origen para trasladar)",
        drag_help = "Arrastra figuras para moverlas.",
        deselect_help = "Haz clic fuera para deseleccionar.",
        close = "Cerrar"
    },

    -- Sidebar
    sidebar = {
        title = "Figuras",
        no_figures = "Aún no hay figuras",
        point_label = "P{index}: ({x}, {y})",
        line_label = "L{index}:",
        figure_label = "F{index}"
    },

    -- Problem system
    problems = {
        title = "Problemas",
        select_activity = "Selecciona una actividad:",
        difficulty = "Dificultad",
        easy = "Fácil",
        medium = "Media",
        hard = "Difícil",
        start = "Comenzar",
        next = "Siguiente Problema",
        check = "Verificar Respuesta",
        hint = "Pista",
        your_answer = "Tu Respuesta",
        correct = "¡Correcto!",
        incorrect = "No del todo. ¡Inténtalo de nuevo!",
        completed = "¡Actividad completada!",
        score = "Puntuación: {score}%",
        back = "Volver al Menú",

        -- Feedback messages
        feedback = {
            no_answer = "¡Por favor proporciona una respuesta primero!",
            incorrect = "No del todo. ¡Inténtalo de nuevo!",
            correct = "¡Correcto! ¡Bien hecho!"
        },

        -- Problem types
        types = {
            plot_points = "Graficar Puntos",
            measure_distance = "Medir Distancia",
            find_slope = "Hallar Pendiente",
            draw_line_with_slope = "Dibujar Línea con Pendiente",
            check_colinearity = "Verificar Colinealidad",
            find_equation = "Hallar Ecuación",
            find_midpoint = "Hallar Punto Medio",
            parallel_lines = "Líneas Paralelas",
            perpendicular_lines = "Líneas Perpendiculares"
        }
    },

    -- Problem types
    problem_types = {
        plot_points = "Graficar Puntos",
        measure_distance = "Medir Distancia",
        find_slope = "Hallar Pendiente",
        draw_line_with_slope = "Dibujar Línea con Pendiente",
        check_colinearity = "Verificar Colinealidad",
        find_equation = "Hallar Ecuación",
        find_midpoint = "Hallar Punto Medio",
        parallel_lines = "Líneas Paralelas",
        perpendicular_lines = "Líneas Perpendiculares"
    },

    -- Validation messages
    validation = {
        point_placed = "Punto colocado en ({x}, {y})",
        distance_is = "La distancia es {distance}",
        slope_is = "La pendiente es {slope}",
        equation_is = "La ecuación es y = {slope}x + {intercept}",
        points_are_colinear = "Los puntos son colineales",
        points_not_colinear = "Los puntos no son colineales",
        correct_answer = "¡Correcto! ¡Buen trabajo!",
        wrong_answer = "Eso no es correcto. ¡Inténtalo de nuevo!",
        close_answer = "¡Estás cerca! Revisa tu cálculo."
    },

    -- Geometric terms
    geometry = {
        point = "punto",
        line = "línea",
        slope = "pendiente",
        y_intercept = "intersección y",
        distance = "distancia",
        midpoint = "punto medio",
        coordinates = "coordenadas",
        equation = "ecuación",
        parallel = "paralelo",
        perpendicular = "perpendicular",
        colinear = "colineal",
        horizontal = "horizontal",
        vertical = "vertical"
    },

    -- Common words
    common = {
        yes = "Sí",
        no = "No",
        ok = "Aceptar",
        cancel = "Cancelar",
        save = "Guardar",
        load = "Cargar",
        delete = "Eliminar",
        edit = "Editar",
        create = "Crear",
        clear = "Limpiar",
        reset = "Restablecer",
        back = "Volver",
        close = "Cerrar"
    }
}
