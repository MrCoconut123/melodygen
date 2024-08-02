import os
import json
import re
import subprocess
import replicate
api_token = os.getenv('REPLICATE_API_TOKEN')

def generate_audio(audio_path, prompt, duration):
    """
    Generates an audio output based on the input audio file and prompt using the Replicate API.
    Args:
        audio_path (str): The file path to the input audio file that will be used as a base.
        prompt (str): A text prompt to guide the audio generation process.
        duration (int): The desired duration of the generated audio in seconds.
    Returns:
        None: The function prints the URL of the generated audio output.
    Example:
        generate_audio("path/to/audio/file.wav", "A cheerful melody with piano and strings", 30)
    """
    input_audio= uploadMelody(audio_path)  
    print(f"generating audio ...")
    #calling meta's music mode 
    output_audio = replicate.run(
    "meta/musicgen:671ac645ce5e552cc63a54a2bbff63fcf798043055d2dac5fc9e36a837eedcfb",
    input={
        "top_k": 250,
        "top_p": 0,
        "prompt": prompt,
        "duration": duration,
        "input_audio": input_audio,
        "temperature": 1,
        "continuation": False,
        "model_version": "stereo-large",
        "output_format": "mp3",
        "continuation_start": 0,
        "multi_band_diffusion": False,
        "normalization_strategy": "peak",
        "classifier_free_guidance": 3
    }
)
    print(output_audio)

    #downloading generated audio
    output_local = download_song(output_audio, prompt)
    output_firebase = uploadMelody(download_audio)
    remove_audio = (input_audio)
    remove_audio = (output_local)

    return output_firebase

def download_song(audio_path, description):
    description = re.sub(r'[^a-zA-Z]', '', description)[:15]
    local_filename = f"{description}.mp3"
    subprocess.run(["curl", audio_path, "-k","-o",local_filename])
    print(f"download music to {local_filename}")
    return local_filename
        
def remove_audio(audio_path):
    if os.path.exists(audio_path):
        print(f"Removing audio file{audio_path}")
        os.remove(audio_path)