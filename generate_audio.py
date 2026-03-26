"""
generate_audio.py
Run this in the root of your Flutter project:
    python generate_audio.py

Requires: pip install numpy
Generates 4 WAV-based MP3 placeholder audio files for Think Fast.
"""

import numpy as np
import wave
import os
import struct


def generate_tone(filename: str, freq: float, duration_ms: int, volume: float = 0.45):
    sample_rate = 44100
    samples = int(sample_rate * duration_ms / 1000)
    t = np.linspace(0, duration_ms / 1000, samples, endpoint=False)

    # Sine wave
    data = np.sin(2 * np.pi * freq * t)

    # Smooth fade-out to avoid click
    fade_len = min(int(sample_rate * 0.03), samples)
    fade = np.ones(samples)
    fade[-fade_len:] = np.linspace(1.0, 0.0, fade_len)
    data = data * fade * volume

    # 16-bit PCM
    pcm = (data * 32767).astype(np.int16)

    # Write WAV, then rename to .mp3
    # audioplayers on Android handles both WAV and MP3;
    # using WAV data with .mp3 extension works fine for dev/production
    # Replace with real MP3s from freesound.org for best quality.
    wav_path = filename.replace(".mp3", "_tmp.wav")
    with wave.open(wav_path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(pcm.tobytes())

    if os.path.exists(filename):
        os.remove(filename)
    os.rename(wav_path, filename)
    print(f"  ✓  {filename}  ({duration_ms}ms @ {int(freq)}Hz)")


def main():
    os.makedirs("assets/audio", exist_ok=True)
    print("Generating audio files for Think Fast...\n")

    generate_tone("assets/audio/correct.mp3",       freq=880,  duration_ms=160)
    generate_tone("assets/audio/wrong.mp3",          freq=200,  duration_ms=220)
    generate_tone("assets/audio/countdown_tick.mp3", freq=660,  duration_ms=80)
    generate_tone("assets/audio/round_end.mp3",      freq=440,  duration_ms=400)

    print("\n✅  4 audio files created in assets/audio/")
    print("   Tip: replace with real MP3s from freesound.org for best quality.")


if __name__ == "__main__":
    main()
