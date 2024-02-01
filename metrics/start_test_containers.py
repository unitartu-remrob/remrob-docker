from dotenv import load_dotenv
import os
import requests
import sys
import time
import subprocess
import webbrowser
# import urllib.request 
# from selenium import webdriver
# from selenium.webdriver.common.keys import Keys
# from selenium.webdriver.common.by import By

load_dotenv('.env')

host = os.getenv('HOST')
jwt_token = os.getenv('JWT_TOKEN')

if (len(sys.argv) > 1):
	NUM_CONTAINERS = int(sys.argv[1])
else:
	NUM_CONTAINERS = 1


BROWSER = 'google-chrome'
BROWSER_PROCESS_NAME = 'chrome'

urls = []
start_from = 3

def start_containers(num_containers=1):
    headers = {'Authorization': f'Bearer {jwt_token}'}

    for i in range(num_containers):
        container_name = f"robosim-{start_from+i}"  # Adjust the naming scheme as needed
        url = f"http://{host}/containers/start/{container_name}?is_simulation=true"
        response = requests.post(url, headers=headers)
        if (response.status_code == 200):
            print(response.json())
            url = f"http://{host}{response.json()['path']}"
            urls.append(url)
            print(f"Container url:", url)
    open_novnc()

def open_novnc():
    for url in urls:
        webbrowser.get(BROWSER).open_new_tab(url)
        time.sleep(0.2)

def close_novnc():
    os.system(f"killall -9 '{BROWSER_PROCESS_NAME}'")

def stop_containers(num_containers=1):
    headers = {'Authorization': f'Bearer {jwt_token}'}

    for i in range(num_containers):
        container_name = f"robosim-{start_from+i}"  # Adjust the naming scheme as needed
        url = f"http://{host}/containers/stop/{container_name}"
        response = requests.post(url, headers=headers)
        print(f"Status for {container_name}: {response.status_code}")

def remove_containers(num_containers=1):
    headers = {'Authorization': f'Bearer {jwt_token}'}

    for i in range(num_containers):
        container_name = f"robosim-{start_from+i}"  # Adjust the naming scheme as needed
        url = f"http://{host}/containers/remove/{container_name}"
        response = requests.post(url, headers=headers)
        print(f"Status for {container_name}: {response.status_code}")



def exec_command_in_containers(num_containers=1, command="echo 'Hello, World!'"):
    for i in range(num_containers):
        container_name = f"robosim-{start_from+1}"  # Adjust the naming scheme as needed
        subprocess.run(["docker", "exec", container_name, "bash", "-c", command])

if __name__ == '__main__':
    start_containers(NUM_CONTAINERS)
    time.sleep(10)
    # exec_command_in_containers(NUM_CONTAINERS, "xdotool windowkill $(xdotool search --name '^Gazebo$' | head -n 1)")
    time.sleep(6)
    stop_containers(NUM_CONTAINERS)
    time.sleep(4)
    close_novnc()
    remove_containers(NUM_CONTAINERS)
