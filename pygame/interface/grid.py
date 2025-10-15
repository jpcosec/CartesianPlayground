import numpy as np
import pygame

from config import COLOR_DARK_GRAY, COLOR_BLACK


class Grid:
    def __init__(self, width, height, cell_size, header_height, font, screen):
        self.width = width
        self.height = height
        self.cell_size = cell_size
        self.header_height = header_height
        self.screen_center = np.array((self.width // 2, (self.height + self.header_height) // 2))
        self.cartesian_center = np.array((0, 0))
        self.cartesian_range = np.array(
            (self.width / (self.cell_size * 2), (self.height + self.header_height) / (self.cell_size * 2)))

        self.font = font
        self.screen = screen

    def draw_grid(self):
        for x in range(0, self.width + 1, self.cell_size):
            color = (0, 0, 0) if x == self.screen_center[0] else (220, 220, 220)
            pygame.draw.line(self.screen, color, (x, self.header_height), (x, self.height + self.header_height))

        for y in range(self.header_height, self.header_height + self.height + 1, self.cell_size):
            color = (0, 0, 0) if y == self.screen_center[1] else (220, 220, 220)
            pygame.draw.line(self.screen, color, (0, y), (self.width, y))

        for n, x in zip(np.arange(self.cartesian_range[0] * -1, self.cartesian_range[0]),
                        range(0, self.width + 1, self.cell_size)):
            if n % 5 == 0:
                x_label = self.font.render(str(n), True, COLOR_DARK_GRAY)
                self.screen.blit(x_label, (x + 2, self.screen_center[1] + 2))
                pygame.draw.line(self.screen, COLOR_BLACK,
                                 (x, self.screen_center[1] - 5),
                                 (x, self.screen_center[1] + 5))

        for n, y in zip(np.arange(self.cartesian_range[1] * -1, self.cartesian_range[1]),
                        range(self.height + 1, self.header_height + 1, -1 * self.cell_size)):

            if (n % 5 == 0) and (n != self.cartesian_range[1]) and (n != 0):
                y_label = self.font.render(str(n), True, COLOR_DARK_GRAY)
                self.screen.blit(y_label,
                                 (self.screen_center[0] + 2, y + self.cell_size * 2 + 2))
                pygame.draw.line(self.screen, COLOR_BLACK,
                                 (self.screen_center[0] - 5, y + self.cell_size * 2),
                                 (self.screen_center[0] + 5, y + self.cell_size * 2))

    def get_game_coordinates(self, cartesian_pos):
        if type(cartesian_pos) is not np.array:
            cartesian_pos = np.array(cartesian_pos)
        if abs(cartesian_pos - self.cartesian_center) > self.cartesian_range:
            print("coordinates out of range")
        return ((cartesian_pos - self.cartesian_center) * self.cell_size).floor() + self.screen_center

    def get_cartesian_coordinates(self, mouse_pos):
        grid_x = round((mouse_pos[0] / self.cell_size) - self.cartesian_range[0], 2)
        grid_y = round(((self.height - mouse_pos[1] + self.header_height) / self.cell_size) - self.cartesian_range[1],
                       2)
        return grid_x, grid_y
