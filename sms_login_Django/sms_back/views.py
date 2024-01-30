import json
import requests
import logging
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

# Logger settings
logging.basicConfig(level=logging.INFO)

@csrf_exempt
def send_message(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            usernumber = data.get('usernumber')
            random_number = data.get('random_number')

            logging.info(f"Received data: usernumber={usernumber}, random_number={random_number}")

            url = "https://ippanel.com/patterns/pattern"

            # Your panel username
            username = ""

            # Your panel password
            password = ""

            # Sending number
            from_number = ""

            # Your pattern code
            pattern_code = ""

            # The number you want the code to be sent to
            # In this section, it is defined to receive the user's phone number from the text input of the flutter
            to = [usernumber]

            # In this section, it is defined to send a random code. The code of this section is written in Flutter.
            input_data = {
                "code": random_number,
            }
            
            full_url = f"{url}?username={username}&password={password}&from={from_number}&to={json.dumps(to)}&input_data={json.dumps(input_data)}&pattern_code={pattern_code}"

            headers = {
                'Content-Type': 'application/json'
            }

            payload = json.dumps(input_data)

            logging.info("Sending request to SMS service")
            response = requests.post(full_url, headers=headers, data=payload)

            logging.info(f"Received response from SMS service: {response.text}")
            return JsonResponse({"message": "Message sent successfully", "response": response.text})

        except requests.exceptions.RequestException as e:
            logging.error(f"Request to SMS service failed: {e}")
            return JsonResponse({"error": str(e)})

    else:
        logging.error("Invalid request method")
        return JsonResponse({"error": "Invalid request method"})
