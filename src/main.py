import requests
import subprocess
import os
import sys

from anilist.api_client import obtener_token
from ui.interfaz import tu_clase_interfaz


# Endpoint GraphQL de AniList
API_URL = "https://graphql.anilist.co"

def verificar_token():
    """
    Ejecuta api_client.py para obtener y verificar el token.
    """
    print("Ejecutando api_client.py para verificar el token...")
    subprocess.run(["python", "anilist/api_client.py"])

def consulta_anime(id_anime):
    """
    Realiza una consulta para obtener información de un anime.
    
    Args:
        id_anime (int): El ID del anime a consultar.
    
    Returns:
        dict or None: Datos del anime si la consulta es exitosa, None en caso contrario.
    """
    query = """
    query ($id: Int) {
        Media(id: $id, type: ANIME) {
            id
            title {
                romaji
                english
            }
            description
        }
    }
    """
    variables = {"id": id_anime}

    # Obtener el token de acceso
    access_token = obtener_token()

    # Cabecera con el token
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
    }

    # Realizar la consulta
    response = requests.post(API_URL, json={"query": query, "variables": variables}, headers=headers)
    if response.status_code == 401:  # Token inválido
        print("Token inválido. Intenta actualizar el token ejecutando api_client.py de nuevo.")
        return None
    elif response.status_code == 200:
        return response.json()
    else:
        print(f"Error al consultar el anime: {response.status_code}, {response.text}")
        return None

if __name__ == "__main__":
    # Verificar y actualizar el token si es necesario
    verificar_token()

    try:
        id_anime = int(input("Ingresa el ID del anime: "))
        datos = consulta_anime(id_anime)
        if datos:
            # Obtener la descripción en inglés
            descripcion_ingles = datos['data']['Media']['description']
            print("Descripción en inglés:", descripcion_ingles)
    except ValueError:
        print("Por favor, ingresa un ID válido.")