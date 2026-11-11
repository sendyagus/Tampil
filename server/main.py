"""Server deteksi kata pengisi (eee, hmm, emm, anu, dll) dari rekaman suara.

Kenapa perlu server? Mesin suara-ke-teks bawaan ponsel/browser biasanya
MEMBUANG bunyi 'eee' dan 'hmm' dari hasil. Di sini kita memakai Whisper
(dengan petunjuk awal agar bunyi pengisi ikut ditulis) ditambah analisis
energi suara pada jeda di antara kata.
"""
import os
import re
import shutil
import tempfile

import numpy as np
from faster_whisper import WhisperModel
from faster_whisper.audio import decode_audio
from fastapi import FastAPI, File, UploadFile

# "small" cukup untuk CPU laptop. Ganti "base" bila terlalu lambat.
model = WhisperModel("small", compute_type="int8")

# Petunjuk agar Whisper menuliskan bunyi pengisi, bukan membuangnya.
PROMPT = "Eee, hmm, anu, emm, ehm, jadi, nah, gitu. Eee... saya akan, hmm, menjelaskan."

KATA_PENGISI = {"anu", "gitu", "kayak", "kayaknya", "nah", "pokoknya"}
POLA_BUNYI = re.compile(r"(e+h*m*|e+m+|h+m+|u+m+|a+h+|e+r+)")

SR = 16000
HOP = 160  # 10 milidetik


def normal(kata: str) -> str:
    return re.sub(r"[^\w]", "", kata.lower())


def adalah_pengisi(kata: str) -> bool:
    k = normal(kata)
    return k in KATA_PENGISI or bool(POLA_BUNYI.fullmatch(k))


def rms_frames(y: np.ndarray, win: int = 400) -> np.ndarray:
    n = 1 + max(0, (len(y) - win) // HOP)
    idx = np.arange(win)[None, :] + HOP * np.arange(n)[:, None]
    return np.sqrt((y[idx] ** 2).mean(axis=1))


def bunyi_di_jeda(kata, durasi, rms, ambang):
    """Cari bagian jeda antar kata yang masih berisi suara (kemungkinan 'eee')."""
    if not kata:
        return []
    batas = [(0.0, kata[0]["mulai"])]
    batas += [(kata[i]["selesai"], kata[i + 1]["mulai"]) for i in range(len(kata) - 1)]
    batas.append((kata[-1]["selesai"], durasi))
    hasil = []
    for a, b in batas:
        if b - a < 0.35 or b - a > 3.0:
            continue
        seg = rms[int(a * 100):int(b * 100)]
        if len(seg) and (seg > ambang).mean() >= 0.6:
            hasil.append({"kata": "(bunyi pengisi)", "mulai": round(a, 2),
                          "selesai": round(b, 2), "sumber": "suara"})
    return hasil


def deteksi(path: str) -> dict:
    segmen, _ = model.transcribe(
        path, language="id", word_timestamps=True,
        initial_prompt=PROMPT, condition_on_previous_text=False,
    )
    kata = []
    for s in segmen:
        for w in s.words:
            kata.append({"kata": w.word.strip(), "mulai": w.start, "selesai": w.end})

    y = decode_audio(path, sampling_rate=SR)
    durasi = len(y) / SR
    rms = rms_frames(y)
    ambang = max(0.005, 0.2 * float(np.percentile(rms, 90)))

    pengisi = [
        {"kata": k["kata"], "mulai": round(k["mulai"], 2),
         "selesai": round(k["selesai"], 2), "sumber": "teks"}
        for k in kata if adalah_pengisi(k["kata"])
    ]
    pengisi += bunyi_di_jeda(kata, durasi, rms, ambang)
    pengisi.sort(key=lambda x: x["mulai"])

    return {
        "teks": " ".join(k["kata"] for k in kata),
        "durasi_detik": round(durasi, 2),
        "jumlah_pengisi": len(pengisi),
        "pengisi": pengisi,
    }


app = FastAPI()


@app.post("/analisis")
async def analisis(file: UploadFile = File(...)):
    suffix = os.path.splitext(file.filename or "")[1] or ".wav"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as t:
        shutil.copyfileobj(file.file, t)
        path = t.name
    try:
        return deteksi(path)
    finally:
        os.remove(path)
