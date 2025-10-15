import pygame
import pygame.camera
import pygame_gui

from face_detector import StressLevelDetector
import cv2


"""
Uses Pygame Camera module to display a webcam in a window 
"""


class CameraWindow(pygame_gui.elements.UIWindow):

    def __init__(self,
                 ui_manager: pygame_gui.core.interfaces.IUIManagerInterface,
                 rect: pygame.Rect = None,
                 camera_name=None
        ):

        pygame.camera.init()

        if camera_name is None:
            camera_name = pygame.camera.list_cameras()[0]

        if rect is None:
            cam_window_pos = [10, 10]
            rect = pygame.Rect(0, 0, 400, 300)
            rect.topleft = cam_window_pos

        super().__init__(rect, ui_manager, window_display_title=camera_name, resizable=True)

        self.show_image = True


        self.camera = None

        self.camera = pygame.camera.Camera(camera_name, (640, 480))
        self.camera.start()

        print(self.camera.get_controls())

        cam_rect = pygame.Rect((0, 0), self.get_container().rect.size)



        self.cam_image = pygame_gui.elements.UIImage(relative_rect=cam_rect,
                                                     image_surface=self.camera.get_image(),
                                                     manager=self.ui_manager,
                                                     container=self,
                                                     anchors={'left': 'left',
                                                              'right': 'right',
                                                              'top': 'top',
                                                              'bottom': 'bottom'})


        self.stress_detector = StressLevelDetector()

    def update(self, time_delta: float):
        super().update(time_delta)

        if self.camera is not None:
            img = self.camera.get_image()

            self.cam_image.set_image(pygame.transform.smoothscale(img,
                                                                  self.get_container().rect.size))

    def opencv2pygame(self, image):
        pygame.image.frombuffer(image.tostring(), image.shape[1::-1], "BGR")

    def get_image(self):
        rgb_content = pygame.surfarray.array3d(
            Camera.cam_image.image
        )

        rgb_content = cv2.cvtColor(
            cv2.transpose(
                cv2.flip(
                    rgb_content
                    , 0)
            ), cv2.COLOR_RGB2BGR
        )

        rgb_content = self.stress_detector(img = rgb_content)
        return rgb_content


if __name__ == '__main__':

    #pygame.camera.init()
    pygame.init()

    pygame.display.set_caption('Quick Start')
    window_surface = pygame.display.set_mode((800, 600))
    manager = pygame_gui.UIManager((800, 600), 'data/themes/quick_theme.json')

    background = pygame.Surface((800, 600))
    background.fill(manager.ui_theme.get_colour('dark_bg'))


    Camera = CameraWindow(manager)

    clock = pygame.time.Clock()
    is_running = True


    while is_running:
        time_delta = clock.tick(60)/1000.0
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                is_running = False

            manager.process_events(event)

        manager.update(time_delta)

        window_surface.blit(background, (0, 0))
        manager.draw_ui(window_surface)

        pygame.display.update()
