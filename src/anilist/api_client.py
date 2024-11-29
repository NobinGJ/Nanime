import requests
import json
import os
import webbrowser

# Configuración para AniList API
CLIENT_ID = '22702'  # Reemplaza con tu client_id
CLIENT_SECRET = 'DjcS5pzDXOKyuxrBGBmDfAtyJqnOU61gFnJrsNlJ'  # Reemplaza con tu client_secret
REDIRECT_URI = 'http://localhost:8080'  # Usa el PIN-based OAuth flow
TOKEN_FILE = 'token.json'

def obtener_token():
    """
    Obtiene un nuevo token de acceso si no existe o si es inválido.
    """
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'r') as file:
            token_data = json.load(file)
        if 'access_token' in token_data and not token_expirado(token_data):
            return token_data['access_token']
    return generar_nuevo_token()

def token_expirado(token_data):
    """
    Verifica si el token ha expirado.
    """
    import time
    current_time = int(time.time())
    return current_time >= token_data.get('expires_at', 0)

def generar_nuevo_token():
    """
    Genera un nuevo token de acceso mediante el flujo de autorización.
    """
    auth_url = f'https://anilist.co/api/v2/oauth/authorize?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code'
    print(f'Abriendo navegador para autorizar la aplicación: {auth_url}')
    webbrowser.open(auth_url)

    auth_code = input('Introduce el código de autorización que obtuviste: ').strip()

    token_url = 'https://anilist.co/api/v2/oauth/token'
    payload = {
        'grant_type': 'authorization_code',
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'redirect_uri': REDIRECT_URI,
        'code': auth_code,
    }
    response = requests.post(token_url, data=payload)
    if response.status_code == 200:
        token_data = response.json()
        guardar_token(token_data)
        return token_data['access_token']
    else:
        print(f'Error al obtener el token: {response.status_code}, {response.text}')
        return None

def guardar_token(token_data):
    """
    Guarda el token en un archivo JSON con la información de expiración.
    """
    import time
    token_data['expires_at'] = int(time.time()) + token_data['expires_in']
    with open(TOKEN_FILE, 'w') as file:
        json.dump(token_data, file)

def actualizar_token():
    """
    Fuerza la obtención de un nuevo token y lo guarda.
    """
    return generar_nuevo_token()

if __name__ == "__main__":
    # Si ejecutas este archivo directamente, obtendrá o actualizará el token
    print("Verificando y generando token si es necesario...")
    token = obtener_token()
    if token:
        print("Token generado/actualizado correctamente y guardado.")
    else:
        print("Hubo un problema al generar el token.")
