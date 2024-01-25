import pygame
from pygame.locals import *

from classes import Cartesian_plane
from header import Header
from user import User
from config import *

from pygame_gui import UIManager, UI_TEXT_ENTRY_CHANGED

class App:
    def __init__(self):
        pygame.init()
        pygame.display.set_caption("Playground Cartesiano")
        self.screen = pygame.display.set_mode(SIZE_DISPLAY)
        self.manager = UIManager(SIZE_DISPLAY)
        self.clock = pygame.time.Clock()
        self.user = User(manager = self.manager)
        self.font = pygame.font.Font(None, FONT_SIZE)

        self.header = Header(HEADER_SIZE, COLOR_HEADER, self.font, self.screen)
        self.grid = Cartesian_plane(self.screen, self.header, self.font)

        self.running = True
        self.moving = False



    def run(self):

        while self.running:
            time_delta = self.clock.tick(60)/1000.0
            self.moving = self.grid.check_movement(self.moving, self.user)
            if self.moving:
                self.grid.move_figure(pos=self.user.mouse_pos)
            self.running = self.user.process_events()

            mouse_pos = None

            self.header.check_buttons(self.user)

            if not self.header.is_mouse_inside(self.user.mouse_pos):

                if self.header.selected_button != "" and self.user.mouse_button_pressed:
                    self.grid.new_figure(self.user, self.header.selected_button)
                    self.header.clear_buttons_state()
                else:
                    mouse_pos = self.grid.run(self.user)
                header_text = self.grid.get_hovered_text()
            else:
                header_text = self.header.selected_button

            self.screen.fill(COLOR_BACKGROUND)

            self.grid.draw(mouse_pos)
            self.header.draw(header_text)
            self.manager.update(time_delta)
            self.manager.draw_ui(self.screen)
            pygame.display.flip()

        pygame.quit()


if __name__ == "__main__":  # todo : clase mensajes # todo : clase problema # todo : colinearity
    app = App()
    app.run()
