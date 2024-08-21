import os 

from flask import Flask, request, jsonify

from audiogenerator import generate_audio


app = Flask(__name__)
upload_folder = "UPLOAD"
app.config ['UPLOAD FOLDER'] = upload_folder

if not os.path.exists(upload_folder):
    os.mkdir(upload_folder)

@app.route('/generate_melody', methods=['POST'])
def process_audio():
    duration = 15 # Default duration of 15 seconds

    # Checking if all required inputs are present
    if 'audio' not in request.files or 'prompt' not in request.form:
        return jsonify({'error': 'Missing audio file or prompt'}), 400
    
    # Retrieving  inputs
    audio_file = request.files['audio']
    prompt = request.form['prompt']
    duration = int(request.form['duration'])

    # Storing audio file 
    audio_filename = audio_file.filename
    audio_path = os.path.join(upload_folder, audio_filename)
    audio_file.save(audio_path)

    # Generating audio
    audio_url = generate_audio(audio_path, prompt, duration)

    print(f'Generated audio URL: {audio_url}')
    return audio_url

if __name__ == '__main__':
    app.run(host='0.0.0.0')
    
