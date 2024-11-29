import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget

class VentanaPrincipal(QMainWindow):
    def __init__(self):
        super().__init__()

        # Configuración básica de la ventana
        self.setWindowTitle("Nanime - Interfaz")
        self.setGeometry(100, 100, 1024, 768)

        # Widget central
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)

        # Layout principal
        self.layout_principal = QVBoxLayout(self.central_widget)

        # Elementos de la interfaz
        self.label_bienvenida = QLabel("¡Bienvenido a Nanime!")
        self.layout_principal.addWidget(self.label_bienvenida)

        # Aquí puedes agregar más widgets como botones, listas, etc.

if __name__ == "__main__":
    app = QApplication(sys.argv)
    ventana = VentanaPrincipal()
    ventana.show()
    sys.exit(app.exec_())
