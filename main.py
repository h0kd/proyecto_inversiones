import webbrowser
from threading import Timer
from app import app  # Asegúrate de que "app" es el nombre de tu archivo principal de Flask

# URL para abrir en el navegador

if __name__ == "__main__":
    # Abrir el navegador después de un breve retraso
    app.run(debug=False, port=5000)  # Asegúrate de usar el puerto adecuado
