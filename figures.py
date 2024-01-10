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
