from PyQt5.QtWidgets import (QApplication, QMainWindow, QLabel, QVBoxLayout, 
                             QHBoxLayout, QGridLayout, QPushButton, QScrollArea, QWidget)
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QSize

from PyQt5.QtCore import Qt

class VentanaPrincipal(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Nanime - Home - By NobinGZ")
        self.setGeometry(100, 100, 1024, 768)

        # Establecer el icono de la ventana
        self.setWindowIcon(QIcon("/assets/icons.ico"))

        if __name__ == "__main__":
            app = QApplication([])
            ventana = VentanaPrincipal()
            ventana.show()
            app.exec_()

        # Widget central
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)

        # Layout principal (Horizontal: Panel lateral + Contenido principal)
        layout_principal = QHBoxLayout(self.central_widget)

        # Panel de navegación lateral
        self.crear_panel_lateral(layout_principal)

        # Contenido principal
        self.contenido_principal = QVBoxLayout()
        layout_principal.addLayout(self.contenido_principal)

        # 1. Encabezado (Perfil)
        self.crear_encabezado()

        # 2. Sección "Continuar"
        self.crear_seccion("Continuar")

        # 3. Sección "Últimas Actualizaciones"
        self.crear_seccion("Últimas Actualizaciones")

        # 4. Sección "Populares"
        self.crear_seccion("Populares")

    def crear_panel_lateral(self, layout_principal):
        panel_lateral = QVBoxLayout()
        
        # Crear los botones de navegación
        boton_calendario = QPushButton("📅")
        boton_perfil = QPushButton("👤")
        boton_settings = QPushButton("⚙️")

        # Alinear los botones en el panel lateral
        panel_lateral.addWidget(boton_calendario, alignment=Qt.AlignCenter)
        panel_lateral.addWidget(boton_perfil, alignment=Qt.AlignCenter)  # Centrando
        panel_lateral.addWidget(boton_settings, alignment=Qt.AlignCenter)

        # Agregar el panel lateral al layout principal
        layout_principal.addLayout(panel_lateral)

    def crear_encabezado(self):
        layout_encabezado = QHBoxLayout()
        
        # Imagen de perfil (placeholder)
        perfil = QLabel("🧑‍🎤")  # Puedes usar un ícono aquí o una imagen real
        perfil.setStyleSheet("font-size: 48px;")  # Estilo para agrandar
        layout_encabezado.addWidget(perfil)

        # Detalles del perfil
        detalles = QVBoxLayout()
        detalles.addWidget(QLabel("Nombre perfil (AniList)"))
        detalles.addWidget(QLabel("Total anime: 100"))
        detalles.addWidget(QLabel("Episodios vistos: 1500"))
        layout_encabezado.addLayout(detalles)

        # Botón de búsqueda
        boton_buscar = QPushButton("🔍 Buscar")
        boton_buscar.setFixedWidth(100)
        layout_encabezado.addWidget(boton_buscar)

        self.contenido_principal.addLayout(layout_encabezado)

    def crear_seccion(self, titulo):
        # Título de la sección
        label_titulo = QLabel(titulo)
        label_titulo.setStyleSheet("font-weight: bold; font-size: 18px;")
        self.contenido_principal.addWidget(label_titulo)

        # Carrusel (placeholder)
        layout_carrusel = QGridLayout()
        for i in range(5):  # Crear 5 elementos de prueba
            item = QLabel(f"Name de anime {i+1}")
            item.setStyleSheet("border: 1px solid black; padding: 10px;")
            layout_carrusel.addWidget(item, 0, i)

        # Scroll Area
        scroll = QScrollArea()
        scroll_widget = QWidget()
        scroll_widget.setLayout(layout_carrusel)
        scroll.setWidget(scroll_widget)
        scroll.setWidgetResizable(True)

        self.contenido_principal.addWidget(scroll)

if __name__ == "__main__":
    app = QApplication([])
    ventana = VentanaPrincipal()
    ventana.show()
    app.exec_()
