import pygame

import numpy as np

from config import *

from .figures import Figure, Point, Line
from .grid import Grid


# init with app

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
        self.hovered_figure = None

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
        elif type == "line":
            self.figures.append(
                Line(
                    user.mouse_pos,
                    self.screen)
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

        self.hovered_figure = None
        for f in self.figures:
            if f.check_hover(user.mouse_pos):
                self.hovered_figure = f
                if user.mouse_button_pressed:
                    f.set_state(True)
                    self.selected_figure = f

    def run(self, user):

        self.check_figures(user)

        return user.mouse_pos

    def get_hovered_text(self):
        if self.hovered_figure:
            return f"{self.hovered_figure} in {self.get_cartesian_coordinates(self.hovered_figure.pos)}"
        else:
            return ""
