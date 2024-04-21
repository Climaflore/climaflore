import requests
import datetime
from colorama import Fore, Style, init

init()  # Initialiser colorama pour permettre la coloration sur Windows

# URL de l'API pour les prévisions météo
url = "https://api.open-meteo.com/v1/forecast"
params = {
    "latitude": 45.7485,
    "longitude": 4.8467,
    "current": "weather_code,cloud_cover,precipitation",
    "hourly": "weather_code,cloud_cover,precipitation_probability,precipitation,rain,showers,snowfall",
    "daily": "weather_code,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_probability_max",
    "timezone": "auto"
}

# Effectuer la requête GET
response = requests.get(url, params=params)
data = response.json()

# Fonction pour obtenir la couleur en fonction du code météo
def get_color(code):
    if code in [0, 1, 2, 85, 86]:
        return Fore.GREEN  # Bonne météo
    elif code in [3, 45, 48, 51, 53, 55, 80, 81]:
        return Fore.YELLOW  # Météo neutre
    elif code in [56, 57, 61, 63, 71, 73]:
        return Fore.LIGHTYELLOW_EX  # Mauvaise météo
    elif code in [65, 66, 67, 75, 82, 95, 96, 99]:
        return Fore.RED  # Météo dangereuse
    else:
        return Fore.WHITE  # Si le code n'est pas reconnu

# Fonction pour convertir le code météo en description
def weather_description(code):
    descriptions = {
        0: "Clear sky",
        1: "Mainly clear",
        2: "Partly cloudy",
        3: "Overcast",
        45: "Fog",
        48: "Depositing rime fog",
        51: "Light drizzle",
        53: "Moderate drizzle",
        55: "Dense drizzle",
        56: "Light freezing drizzle",
        57: "Dense freezing drizzle",
        61: "Slight rain",
        63: "Moderate rain",
        65: "Heavy rain",
        66: "Light freezing rain",
        67: "Heavy freezing rain",
        71: "Slight snowfall",
        73: "Moderate snowfall",
        75: "Heavy snowfall",
        77: "Snow grains",
        80: "Slight rain showers",
        81: "Moderate rain showers",
        82: "Violent rain showers",
        85: "Slight snow showers",
        86: "Heavy snow showers",
        95: "Thunderstorm",
        96: "Thunderstorm with light hail",
        99: "Thunderstorm with heavy hail"
    }
    return descriptions.get(code, "Unknown weather")

# Formater et afficher les prévisions
def display_forecast(data):
    times = data["hourly"]["time"]
    codes = data["hourly"]["weather_code"]
    current_day = None

    for time, code in zip(times, codes):
        day = datetime.datetime.fromisoformat(time).date()
        hour = datetime.datetime.fromisoformat(time).strftime("%H:%M")
        description = weather_description(code)
        color = get_color(code)
        
        if day != current_day:
            if current_day is not None:
                print(Style.RESET_ALL + '-' * 34)
            print(f"{Style.RESET_ALL}             {day.strftime('%A %d/%m')}")
            print(Style.RESET_ALL + '-' * 34)
            current_day = day
        
        print(f"{color}{hour} : {description}{Style.RESET_ALL}")

# Exécuter la fonction d'affichage
display_forecast(data)
