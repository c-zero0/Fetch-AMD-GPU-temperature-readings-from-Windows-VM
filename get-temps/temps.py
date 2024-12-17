import subprocess
import json
import re

def run_cpp_program():
    try:
        result = subprocess.run(["C:\\get-temps\\fetch.exe"], capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print("Error while running the C++ program:", e)
        return None

def parse_output(output):
    # Regular expressions to extract the required values
    temperature_match = re.search(r"The GPU hotspot temperature is: (\d+) C", output)
    power_match = re.search(r"The GPU power is: (\d+) W", output)
    voltage_match = re.search(r"The GPU voltage is: (\d+) mV", output)

    if not (temperature_match and power_match and voltage_match):
        print("Error: Unable to parse the program output.")
        return None

    # Extract and convert the values
    temperature_milidegrees = int(temperature_match.group(1)) * 1000
    power_watts = int(power_match.group(1))
    voltage_volts = int(voltage_match.group(1)) / 1000

    # Create JSON object
    gpu_data = {
        "GPU Hotspot Temperature": temperature_milidegrees,
        "GPU Power": power_watts,
        "GPU Voltage": voltage_volts
    }

    return gpu_data

def main():
    output = run_cpp_program()
    if output:
        gpu_data = parse_output(output)
        if gpu_data:
            # Print JSON formatted string
            print(json.dumps(gpu_data, indent=4))
    #print(output)

if __name__ == "__main__":
    main()