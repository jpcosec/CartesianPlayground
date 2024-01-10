import pygame

import numpy as np

from config import *

from figures import Figure, Point
from grid import Grid


#init with app
class oldLine:
    def __init__(self, start_point):
        self.start_point = start_point
        self.slope = None
        self.b = 0
        self.hovering = False  # Adding a hovering attribute
        self.dragging = False

    def check_hover(self, mouse_pos):
        # Some logic to determine if mouse is close to the line
        # This is a simplified example, you might need more sophisticated distance checking
        if self.slope is not None:
            b = self.start_point[1] - self.slope * self.start_point[0]
            y = self.slope * mouse_pos[0] + b
            self.hovering = abs(mouse_pos[1] - y) < 10  # Assuming 10 as a reasonable proximity range


    def check_click(self, mouse_pos):
        self.check_hover(mouse_pos)
        if self.hovering:
            self.dragging = not self.dragging

    def draw(self, screen):
        color = COLOR_BLACK if not self.hovering else (255, 0, 0)  # Change color if hovering
        if self.slope is not None and self.slope!=0:

            # Here, you calculate the y-coordinates for the left and right ends of the screen
            # using the line equation y = mx + b, ensuring that the line passes through the start point
            y0 = self.slope * 0 + self.b
            y1 = self.slope * CONFIG_SCREEN_WIDTH + self.b

            y0 = np.clip(y0, 0, CONFIG_SCREEN_HEIGHT)
            x0 = (y0 - self.b) / self.slope

            y1 = np.clip(y1, 0, CONFIG_SCREEN_HEIGHT)
            x1 = (y1 - self.b) / self.slope

            # Draw the line from (0, y0) to (screen_width, y1), clipped to the screen height
            pygame.draw.line(screen, color, (x0, y0),(x1, y1), 2)

            # Tengo ecuacion de la recta y punto 0 (x_start,y_start)
            # Tengo x0 = 0 y x1 = screen_width
            # Calculo y0, y1



        else:
            pygame.draw.line(screen, COLOR_BLACK, (self.start_point[0], 0), (self.start_point[0], 600), 3)

        if self.hovering:
            pygame.draw.circle(screen, (0, 255, 0), self.start_point, 5)

    def set_slope(self, end_point):
        if end_point[0] != self.start_point[0]:#abs value
            self.slope = (end_point[1] - self.start_point[1]) / abs(end_point[0] - self.start_point[0])

            self.b = self.start_point[1] - self.slope * self.start_point[0]



class Line(Figure):
    def __init__(self,
                 pos,
                 slope,
                 screen,
                 ):
        super().__init__(
            pos,
            screen,
            font=None,
        )
        self.pos = pos
        self.slope = None

        self.pos = (self.pos[0] , self.pos[1] )

        self.rect = None
        self.draw()


    def move(self, pos = None, rel = None):
        if pos:
            self.pos = pos
        else:
            self.pos = (self.pos[0]+rel[0], self.pos[1]+rel[1])

    def draw(self):
        color = self.colors["hover"] if self.is_hovered else \
                self.colors["selected"] if self.selected else \
                self.colors["pasive"]

        self.rect = pygame.draw.circle(self.screen, color, self.pos, self.radius)




class Cartesian_plane(Grid):
    def __init__(self, screen, header, font):
        self.screen = screen
        self.header = header
        self.font = font

        super().__init__(self.screen.get_width(),
                         self.screen.get_height() - self.header.height,
                         20,
                         self.header.height,
                         self.font,
                         self.screen)

        self.figures = []
        self.selected_figure = None

    def draw(self, mouse_pos=None):
        self.draw_grid()
        for figure in self.figures:
            figure.draw()

        if mouse_pos:  # draw coordinates on screen
            mouse_grid_pos = self.get_cartesian_coordinates(mouse_pos)
            grid_text = "    {}, {}".format(*mouse_grid_pos)
            text_surf = self.font.render(grid_text, True, COLOR_RED)
            self.screen.blit(text_surf, mouse_pos)

    def move_figure(self, pos=None, rel=None):
        if pos:
            self.selected_figure.move(pos=pos)
        else:
            self.selected_figure.move(rel=rel)

    def clear_figures_state(self):
        for v in self.figures:
            v.set_state(False)

    def new_figure(self, user, type):

        if type == "figure":
            self.figures.append(
                Figure(
                    user.mouse_pos,
                    self.screen,
                    self.font)
            )
        elif type == "point":
            self.figures.append(
                Point(
                    user.mouse_pos,
                    self.screen, )
            )

    def check_movement(self, moving, user):
        if self.selected_figure is None:
            return False
        elif user.mouse_button_pressed:
            if self.selected_figure.check_hover and user.mouse_motion:
                moving = True
        else:
            moving = False

        return moving

    def check_figures(self, user):
        if self.selected_figure:
            if user.mouse_button_pressed:
                if user.mouse_motion:
                    # self.selected_figure.move(user.mouse_rel)
                    return None
            else:
                self.selected_figure = None

        if user.mouse_button_pressed:
            self.clear_figures_state()

        for f in self.figures:
            if f.check_hover(user.mouse_pos) and user.mouse_button_pressed:
                f.set_state(True)
                self.selected_figure = f

    def run(self, user):

        self.check_figures(user)

        return user.mouse_pos
