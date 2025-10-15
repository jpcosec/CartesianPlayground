import numpy as np
import pygame

from config import COLOR_BUTTON_PASIVE, COLOR_BUTTON_HOVERED, COLOR_BUTTON_ACTIVE, COLOR_BLACK


class Figure:
    def __init__(self,
                 pos,
                 screen,
                 font,
                 callback=None,
                 text=None,
                 size=[10, 10]
                 ):

        self.text = text
        self.callback = callback
        self.pos = np.array(pos)
        self.size = np.array(size)
        self.screen = screen
        self.font = font
        self.color = COLOR_BUTTON_PASIVE

        self.selected = False
        self.is_hovered = False

        self.rect = pygame.Rect(self.pos, self.size)

        self.colors = {"hover": COLOR_BUTTON_HOVERED,
                       "selected": COLOR_BUTTON_ACTIVE,
                       "pasive": COLOR_BUTTON_PASIVE
                       }


    def __str__(self):
        return "figure"

    def check_hover(self, mouse_pos):
        if self.rect.collidepoint(mouse_pos):
            self.is_hovered = True
        else:
            self.is_hovered = False
        return self.is_hovered

    def move(self, rel=None, pos=None):
        if rel:
            self.rect.move_ip(rel)
        else:
            self.rect.x, self.rect.y = pos

    def set_state(self, value):
        self.selected = value

    def draw(self):

        color = self.colors["hover"] if self.is_hovered else \
            self.colors["selected"] if self.selected else \
                self.colors["pasive"]

        pygame.draw.rect(self.screen, color, self.rect)

        if self.text:
            text_surface = self.font.render(self.text, True, COLOR_BLACK)
            # Center the text in the button
            text_rect = text_surface.get_rect(center=self.pos + self.size / 2
                                              )
            self.screen.blit(text_surface, text_rect)


class Point(Figure):
    def __init__(self,
                 pos,
                 screen,
                 radius=4
                 ):
        super().__init__(
            pos,
            screen,
            font=None,
        )
        self.radius = radius
        self.size = [self.radius * 2, self.radius * 2]
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


class Line(Figure): # TODO: manage coordenadas cartesianas
    def __init__(self,
                 pos,
                 screen,
                 ):
        super().__init__(
            pos,
            screen,
            font=None,
        )
        self.range = 1000
        self.width = 2
        self.proximity_range = 4

        # self.pos = (self.pos[0], self.pos[1])  # initial point

        self.slope = 0
        self.b = None
        self.coords = None

        # self.set_slope(end)
        self.set_b()
        self.set_coords()

        self.rect = None
        self.orig_rect = None

        self.setting_slope = True
        self.initialized = False

        self.draw()

    def set_slope(self, end):
        if end[0] == self.pos[0]:
            self.slope = np.inf
        else:
            self.slope = (end[1] - self.pos[1]) / (end[0] - self.pos[0])

    def set_b(self):
        self.b = self.pos[1] - (self.slope * self.pos[0])

    def set_coords(self): # TODO: Manage division por 0
        s = (self.pos[0] - self.range, ((self.pos[0] - self.range) * self.slope) + self.b)
        e = (self.pos[0] + self.range, ((self.pos[0] + self.range) * self.slope) + self.b)
        self.coords = (s, e)

    def move(self, pos=None, rel=None):
        # print("moving", np.array(pos)-np.array(self.pos))
        if self.setting_slope:
            self.set_slope(pos)
        else:
            if pos:
                self.pos = pos
            else:
                self.pos = (self.pos[0] + rel[0], self.pos[1] + rel[1])

        self.set_b()
        self.set_coords()

    def draw(self):
        color = self.colors["hover"] if self.is_hovered else \
            self.colors["selected"] if self.selected else \
                self.colors["pasive"]

        self.rect = pygame.draw.aaline(self.screen, color, self.coords[0], self.coords[1])#, self.width)

        if self.is_hovered:
            if self.setting_slope:
                self.orig_rect = pygame.draw.circle(self.screen, color, self.pos, self.proximity_range)
            else:
                self.orig_rect = pygame.draw.circle(self.screen, (0,255,255), self.pos, self.proximity_range)

    def distance_to_line(self, pos):
        # y = m*x + b / for ax+by+c=0 abs(ax+by+c)/sqrt(a**2+b**2)
        return abs((-1 * pos[1]) + (self.slope * pos[0]) + self.b) / np.sqrt(1 + (self.slope ** 2))

    def check_hover(self, mouse_pos):
        # split hover
        self.initialized = self.selected or self.initialized

        if self.slope is not None:
            if self.distance_to_line(mouse_pos) < self.proximity_range:
                self.is_hovered = True
                if self.orig_rect is not None:
                    if self.orig_rect.collidepoint(mouse_pos) and self.initialized:
                        self.setting_slope = False
                    else:
                        self.setting_slope = True
            else:
                self.is_hovered = False
        return self.is_hovered
