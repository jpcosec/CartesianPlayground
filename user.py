import pygame

class User:
    def __init__(self):
        self.keys_pressed = []
        self.mouse_button_pressed = False
        self.mouse_pos = (0, 0)
        self.mouse_motion = False
        self.mouse_rel = (0, 0)  # Relative mouse movement
        self.mouse_buttons = [0, 0, 0]  # Left, Middle, Right

    def process_events(self):
        # Go through all the events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.handle_quit()
                return False
            elif event.type in (pygame.KEYDOWN, pygame.KEYUP):
                self.handle_key_event(event)
            elif event.type in (pygame.MOUSEBUTTONDOWN, pygame.MOUSEBUTTONUP):
                self.handle_mouse_button_event(event)

            if event.type == pygame.MOUSEMOTION:
                self.handle_mouse_motion(event)
            else:
                self.mouse_motion = False
                self.mouse_rel = (0, 0)

        return True

    def handle_quit(self):
        pygame.quit()

    def handle_key_event(self, event):
        if event.type == pygame.KEYDOWN:
            if event.key not in self.keys_pressed:
                self.keys_pressed.append(event.key)
        elif event.type == pygame.KEYUP:
            if event.key in self.keys_pressed:
                self.keys_pressed.remove(event.key)

    def handle_mouse_button_event(self, event):
        # Update the mouse button state and position
        if event.type == pygame.MOUSEBUTTONDOWN:
            self.mouse_button_pressed = True
            self.mouse_buttons[event.button-1] = 1  # Mouse buttons are 1-indexed in pygame
        elif event.type == pygame.MOUSEBUTTONUP:
            self.mouse_button_pressed = False
            self.mouse_buttons[event.button-1] = 0

        self.mouse_pos = event.pos

    def handle_mouse_motion(self, event):
        self.mouse_motion = True
        self.mouse_pos = event.pos
        self.mouse_rel = event.rel

    # Additional methods to define user behavior can be added here
if __name__ == '__main__':
    # Usage Example

    pygame.init()
    screen = pygame.display.set_mode((800, 600))
    user = User()

    # Main loop
    running = True
    while running:
        user.process_events()
        screen.fill((0, 0, 0))  # Clear the screen with black

        # Handling mouse position for rendering or logic
        if user.mouse_button_pressed:
            pygame.draw.circle(screen, (255, 0, 0), user.mouse_pos, 10)  # Draw a red circle at the mouse position

        # Handling continuous movement while the mouse button is pressed
        if user.mouse_motion and user.mouse_button_pressed:
            pygame.draw.line(screen, (255, 255, 255), user.mouse_pos, (user.mouse_pos[0] + user.mouse_rel[0], user.mouse_pos[1] + user.mouse_rel[1]))

        # Update the display
        pygame.display.flip()

        # End of main loop check for quitting the game
        if not pygame.get_init():
            running = False

    pygame.quit()
