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
    "hourly": "weather_code,cloud_cover,precipitation_probability,precipitation,rain,showers,snowfall,temperature_2m,apparent_temperature,uv_index,pressure_msl",
    "daily": "weather_code,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_probability_max",
    "timezone": "auto"
}

# Effectuer la requête GET
response = requests.get(url, params=params)
data = response.json()

# Fonctions pour déterminer les couleurs en fonction des valeurs
def color_weather(code):
    if code in [0, 1, 2, 85, 86]:
        return Fore.GREEN
    elif code in [3, 45, 48, 51, 53, 55, 80, 81]:
        return Fore.YELLOW
    elif code in [56, 57, 61, 63, 71, 73]:
        return Fore.LIGHTYELLOW_EX
    elif code in [65, 66, 67, 75, 82, 95, 96, 99]:
        return Fore.RED
    else:
        return Fore.WHITE

def color_temperature(temp):
    if temp < 0:
        return Fore.BLUE  # Très froid: bleu
    elif 0 <= temp < 10:
        return Fore.CYAN  # Froid: cyan
    elif 10 <= temp < 20:
        return Fore.GREEN  # Bon: vert
    elif 20 <= temp < 30:
        return Fore.YELLOW  # Chaud: jaune
    else:
        return Fore.RED  # Très chaud: rouge


def color_uv(uv_index):
    if uv_index < 3:
        return Fore.GREEN
    elif 3 <= uv_index < 6:
        return Fore.YELLOW
    elif 6 <= uv_index < 8:
        return Fore.LIGHTYELLOW_EX
    else:
        return Fore.RED

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

# Formater et afficher les prévisions avec couleurs pour chaque attribut
def display_forecast(data):
    times = data["hourly"]["time"]
    codes = data["hourly"]["weather_code"]
    temperatures = data["hourly"]["temperature_2m"]
    feels_like = data["hourly"]["apparent_temperature"]
    uv_indices = data["hourly"]["uv_index"]
    pressures = data["hourly"]["pressure_msl"]
    probabilities = data["hourly"]["precipitation_probability"]
    current_day = None

    for time, code, temp, feel, uv, pressure, probability in zip(times, codes, temperatures, feels_like, uv_indices, pressures, probabilities):
        day = datetime.datetime.fromisoformat(time).date()
        hour = datetime.datetime.fromisoformat(time).strftime("%H:%M")
        description = weather_description(code)
        weather_col = color_weather(code)
        temp_col = color_temperature(temp)
        feel_col = color_temperature(feel)
        uv_col = color_uv(uv)
        
        if day != current_day:
            if current_day is not None:
                print(Style.RESET_ALL + '-' * 34)
            print(f"{Style.RESET_ALL}             {day.strftime('%A %d/%m')}")
            print(Style.RESET_ALL + '-' * 34)
            current_day = day
        
        # Format and color output for each attribute
        print(f"{hour} : {weather_col}{description}{Style.RESET_ALL} | {temp_col}Temp: {temp}°C{Style.RESET_ALL} | {feel_col}Feels Like: {feel}°C{Style.RESET_ALL} | {uv_col}UV Index: {uv}{Style.RESET_ALL} | Pressure: {pressure} hPa | Precip Probability: {probability}%")

# Exécuter la fonction d'affichage
display_forecast(data)
def evaluate_conditions(temp, weather_code, precipitation_probability, uv_index, pressure, time):
    formatted_time = datetime.datetime.fromisoformat(time).strftime('%A %d/%m %H:%M')
    messages = []
    
    # Évaluation de la température
    if temp > 30:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Très chaud - {formatted_time}{Style.RESET_ALL}")
    elif temp < 0:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Très froid - {formatted_time}{Style.RESET_ALL}")
    elif 20 <= temp <= 30:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Chaud - {formatted_time}{Style.RESET_ALL}")
    elif 0 <= temp < 10:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Froid - {formatted_time}{Style.RESET_ALL}")
    # elif 10 <= temp < 20:
    #     messages.append(f"{Fore.GREEN}[ + ] Conditions optimales: Température agréable - {formatted_time}{Style.RESET_ALL}")
    
    # Évaluation de la météo
    if weather_code in [95, 96, 99]:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Conditions orageuses sévères - {formatted_time}{Style.RESET_ALL}")
    elif weather_code in [63, 65, 73, 75]:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Précipitations importantes - {formatted_time}{Style.RESET_ALL}")
    elif weather_code in [61, 71, 51]:
        messages.append(f"{Fore.BLUE}[ i ] Surveillance: Légères précipitations - {formatted_time}{Style.RESET_ALL}")
    # elif weather_code in [0, 1, 2, 3]:
    #     messages.append(f"{Fore.GREEN}[ + ] Conditions optimales: Temps clair - {formatted_time}{Style.RESET_ALL}")
    
    # Évaluation de la probabilité de précipitation
    if precipitation_probability > 80:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Probabilité de précipitation très élevée - {formatted_time}{Style.RESET_ALL}")
    elif 50 < precipitation_probability <= 80:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Probabilité de précipitation élevée - {formatted_time}{Style.RESET_ALL}")
    elif 20 < precipitation_probability <= 50:
        messages.append(f"{Fore.BLUE}[ i ] Surveillance: Probabilité de précipitation modérée - {formatted_time}{Style.RESET_ALL}")
    # elif precipitation_probability <= 20:
    #     messages.append(f"{Fore.GREEN}[ + ] Conditions optimales: Faible probabilité de précipitation - {formatted_time}{Style.RESET_ALL}")
    
    # Évaluation de l'indice UV
    if uv_index > 8:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Indice UV très élevé - {formatted_time}{Style.RESET_ALL}")
    elif 6 <= uv_index <= 8:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Indice UV élevé - {formatted_time}{Style.RESET_ALL}")
    elif 3 <= uv_index < 6:
        messages.append(f"{Fore.BLUE}[ i ] Surveillance: Indice UV modéré - {formatted_time}{Style.RESET_ALL}")
    # elif uv_index < 3:
    #     messages.append(f"{Fore.GREEN}[ + ] Conditions optimales: Indice UV faible - {formatted_time}{Style.RESET_ALL}")
    
    # Évaluation de la pression atmosphérique
    if pressure < 1000:
        messages.append(f"{Fore.RED}[ !!! ] Alerte: Pression atmosphérique très basse - {formatted_time}{Style.RESET_ALL}")
    elif 1000 <= pressure < 1013:
        messages.append(f"{Fore.YELLOW}[ ! ] Avertissement: Pression atmosphérique basse - {formatted_time}{Style.RESET_ALL}")
    elif 1013 <= pressure < 1023:
        messages.append(f"{Fore.BLUE}[ i ] Surveillance: Pression atmosphérique normale - {formatted_time}{Style.RESET_ALL}")
    # elif pressure >= 1023:
    #     messages.append(f"{Fore.GREEN}[ + ] Conditions optimales: Pression atmosphérique haute - {formatted_time}{Style.RESET_ALL}")
    
    return messages

# Boucle principale pour afficher les prévisions et collecter les messages d'évaluation
evaluation_messages = []
for time, code, temp, feel, uv, pressure, probability in zip(
    data["hourly"]["time"],
    data["hourly"]["weather_code"],
    data["hourly"]["temperature_2m"],
    data["hourly"]["apparent_temperature"],
    data["hourly"]["uv_index"],
    data["hourly"]["pressure_msl"],
    data["hourly"]["precipitation_probability"]
):
    # Assurez-vous que l'ordre des paramètres correspond à la définition de la fonction
    messages = evaluate_conditions(temp, code, probability, uv, pressure, time)
    evaluation_messages.extend(messages)

# Afficher les prévisions
display_forecast(data)

# Afficher les messages d'évaluation collectés
print("\nConclusions et Avertissements basés sur les données météorologiques :")
for message in evaluation_messages:
    print(message)