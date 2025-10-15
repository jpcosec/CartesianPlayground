import pygame



import threading
import time
import cv2 # OpenCV for camera access

from pygame_gui import UIManager

from interface.cartesian_plane import Cartesian_plane
from interface.header import Header
from interface.user import User
from config import *
from camera.face_detector import StressLevelDetector

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

        # Add the stop event for the camera thread
        self.stop_event = threading.Event()
        self.camera_thread = threading.Thread(target=self.camera_recording_and_saving, args=(self.stop_event,))
        self.camera_thread.start()

        self.stress_detector = StressLevelDetector()
        self.stress_level = ""

    def camera_recording_and_saving(self, stop_event):
        # Initialize the camera (0 is usually the default camera)
        cap = cv2.VideoCapture(0)
        count = 0

        while not stop_event.is_set():
            ret, frame = cap.read()
            if ret:
                self.stress_level = self.stress_detector(frame)
            time.sleep(CAPTURE_TIME)  # Adjust this based on your desired frame rate
        cap.release()

    def run(self):
        while self.running:
            time_delta = self.clock.tick(60) / 1000.0
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


        self.stop_event.set()
        self.camera_thread.join()
        pygame.quit()

        exit()

# todo : clase mensajes
# todo : clase problema
# todo : colinearity
# todo : thread no cierra solo
if __name__ == "__main__":
    app = App()
    app.run()
