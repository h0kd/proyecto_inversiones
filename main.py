import webbrowser
from threading import Timer
from app import app  # Asegúrate de que "app" es el nombre de tu archivo principal de Flask

# URL para abrir en el navegador
def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/")

if __name__ == "__main__":
    # Abrir el navegador después de un breve retraso
    Timer(1, open_browser).start()
    app.run(debug=False, port=5000)  # Asegúrate de usar el puerto adecuado
