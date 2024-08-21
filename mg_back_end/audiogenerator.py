import os
import json
import re
import subprocess

import replicate

from storage_manager import StorageManager

sm = StorageManager()

with open('api_key.json') as f:
    API_KEY = json.load(f)
os.environ["REPLICATE_API_TOKEN"] = API_KEY["API_KEY"]
api = replicate.Client(api_token=os.environ["REPLICATE_API_TOKEN"])


def generate_audio(audio_path, prompt, duration):
    url_audio = uploadMelody(audio_path)

    print(f"Generating audio ...")
    #calling replicate music gen model 
    audio_url = replicate.run(
        "meta/musicgen:671ac645ce5e552cc63a54a2bbff63fcf798043055d2dac5fc9e36a837eedcfb",
        input={
            "top_k": 250,
            "top_p": 0,
            "prompt": prompt,
            "duration": duration,
            "input_audio": url_audio,
            "temperature": 1,
            "continuation": False,
            "model_version": "stereo-melody-large",
            "output_format": "mp3",
            "continuation_start": 0,
            "multi_band_diffusion": False,
            "normalization_strategy": "peak",
            "classifier_free_guidance": 3
        }
    )
    print(audio_url)


    # Download the generated audio
    downloaded_audio = download_song(audio_url, prompt)
    url_audio = uploadMelody(downloaded_audio)
    remove_audio(audio_path)
    remove_audio(downloaded_audio)


    return url_audio

def download_song(audio_path, description):
    description = re.sub(r'[^a-zA-Z]', '', description)[:15]
    local_filename = f"{description}.mp3"
    subprocess.run(["curl", audio_path, "-k", "-o", local_filename])
    print(f"Downloaded music to {local_filename}")

    return local_filename

def remove_audio(audio_path):
    if os.path.exists(audio_path):
        print(f"Removing audio file {audio_path}")
        os.remove(audio_path)

def uploadMelody(audio_path):
    # Upload the file to Firebase
    filename = os.path.basename(audio_path)
    url_audio = sm.upload_file(filename, audio_path)
    print(f"Uploaded audio for {filename}")

    return url_audio

if __name__ == "__main__":
    print(f"Processing audio ...")

    audio_path = "Generate a live.wav"
    prompt = "write in g minor and use a waltz style"
    duration = 15
    generate_audio(audio_path, prompt, duration) 

