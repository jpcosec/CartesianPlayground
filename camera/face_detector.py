import os
from pathlib import Path
import cv2
import numpy as np

from datetime import datetime

class StressLevelDetector:
    def __init__(self, save_frame = True):
        self.face_cascade = cv2.CascadeClassifier('camera/haarcascade_frontalface_default.xml')
        self.stress = 1
        self.frame = None

        self.save_frame = save_frame
        self.init_time = datetime.now().strftime("%m%d%Y%H%M")
        if self.save_frame:

            Path(f"output/{self.init_time}").mkdir(parents=True, exist_ok=True)
            Path(f"frames/{self.init_time}").mkdir(parents=True, exist_ok=True)


        self.img_count = 0


    def get_stress_level(self):
        coin = np.random.rand()
        if coin < 0.05:
            self.stress = max(0, self.stress - 1)
        elif coin > 0.9:
            self.stress = min(self.stress + 1, 4)

        print(coin, self.stress)

        states = ["Totalmente relajado",
                  "Relajado",
                  "Neutro",
                  "Medianamente estresado",
                  "Muy estresado"
                  ]
        return states[self.stress]

    def process_frame(self, img=None, show=False):

        if img is None:
            img = self.frame
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray, 1.1, 4)

        if show:
            for (x, y, w, h) in faces:
                cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
                font = cv2.FONT_HERSHEY_SIMPLEX
                cv2.putText(img, self.get_stress_level(),
                            (x, y), font, 1, (0, 255, 255), 2, cv2.LINE_4)
            cv2.imshow('img', img)

        return img, faces

    def __call__(self, img, imname = "detector"):


        print(".")

        if self.save_frame:
            cv2.imwrite(f"./frames/{self.init_time}/{self.img_count}.jpg", img)

        out_img, frames = self.process_frame(img)
        if self.save_frame:
            with open(f"./output/{self.init_time}/{self.img_count}.csv","w") as file:
                file.write(
                    "\n".join(
                        [",".join([str(a) for a in arr]
                                  ) for arr in frames]
                    )
                )
            self.img_count+=1

        return out_img

if __name__ == "__main__":

    stress_detector = StressLevelDetector()

    cap = cv2.VideoCapture(0)

    while True:
        _ , im = cap.read()
        stress_detector(im)

        k = cv2.waitKey(30) & 0xff
        if k == 27:
            break

    cap.release()
    cv2.destroyAllWindows()


