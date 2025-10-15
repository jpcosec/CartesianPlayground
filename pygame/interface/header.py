import numpy as np
import pygame

from config import HEADER_SIZE, COLOR_BUTTON_PASIVE, COLOR_BUTTON_HOVERED, COLOR_BUTTON_ACTIVE, COLOR_BLACK, COLOR_WHITE

from pygame_gui.elements import UIWindow, UITextEntryBox, UITextBox

class Button:
    def __init__(self,
                 text,
                 pos,
                 screen,
                 font,
                 callback=None,
                 size=[HEADER_SIZE * 2.6, HEADER_SIZE-4]
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

    def check_hover(self, mouse_pos):
        if self.rect.collidepoint(mouse_pos):
            self.is_hovered = True
        else:
            self.is_hovered = False

    def set_state(self,value):
        self.selected = value


    def draw(self):

        color = COLOR_BUTTON_HOVERED if self.is_hovered else \
                COLOR_BUTTON_ACTIVE if self.selected else \
                COLOR_BUTTON_PASIVE


        pygame.draw.rect(self.screen, color, self.rect)
        text_surface = self.font.render(self.text, True, COLOR_BLACK)
        # Center the text in the button
        text_rect = text_surface.get_rect(center=self.pos+self.size/2
                                          )
        self.screen.blit(text_surface, text_rect)


# Crear class message que lea de un dict de html y haga display de instrucciones


class Header:
    def __init__(self, height, color, font, screen,
                 buttons = {# Agregar boton de instrucciones
                     "line": (400, 2),
                     "point": (500,2),
                     "intro": (300,2)
                 }
                 ):
        self.height = height
        self.color = color
        self.font = font
        self.screen = screen

        self.buttons = {k:Button(k,v,self.screen, self.font)
                        for k,v in buttons.items()
                        }
        self.selected_button = ""

        # Crear array de instrucciones
        self.text_intro = None
        self.deploy_intro()


    def deploy_intro(self):
        # Meter instrucciones
        output_window = UIWindow(pygame.Rect(400, 20, 300, 400), window_display_title="instrucciones")
        self.text_intro = UITextBox(
            relative_rect=pygame.Rect((0, 0), output_window.get_container().get_size()),
            html_text="textoTESTO hay que escribir de que se trata esta computacion",
            container=output_window)


    def draw(self, text):
        pygame.draw.rect(self.screen, self.color, (0, 0, self.screen.get_width(), self.height))
        text_surf = self.font.render(text, True, COLOR_WHITE)
        self.screen.blit(text_surf, (10, (self.height - text_surf.get_height()) // 2))

        for button in self.buttons.values():
            button.draw()

    def clear_buttons_state(self):
        for v in self.buttons.values():
            v.set_state(False)
        self.selected_button = ""

    def check_buttons(self, user):
        out = ""
        for k, v in self.buttons.items():
            v.check_hover(user.mouse_pos)
            if v.is_hovered:
                if user.mouse_button_pressed:
                    self.clear_buttons_state()
                    if k == "intro":
                        print("intro")
                        self.deploy_intro()
                        return out
                    v.set_state(True)
                    self.selected_button = k
                    out = k

        return out

    def is_mouse_inside(self, mouse_pos):# todo: return true si hay mensaje deployado
        if self.text_intro.alive():
            return True
        return mouse_pos[1] < self.height
