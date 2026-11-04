"""
Mengukur akurasi model suara -> teks dengan WER (Word Error Rate).

Siapkan folder data_uji berisi pasangan file dengan nama yang sama:
    data_uji/satu.wav   (rekaman)
    data_uji/satu.txt   (teks yang BENAR, sesuai yang diucapkan)
    data_uji/dua.wav
    data_uji/dua.txt
    ...

Jalankan:
    python evaluasi_wer.py
    python evaluasi_wer.py folder_lain
"""
import os
import re
import sys

import jiwer
from faster_whisper import WhisperModel

FOLDER = sys.argv[1] if len(sys.argv) > 1 else "data_uji"
MODEL_UKURAN = os.environ.get("MODEL", "small")
PROMPT = "Eee, hmm, anu, mmm, eh, jadi... hmm."
EKSTENSI = (".wav", ".mp3", ".m4a", ".webm", ".ogg", ".flac")


def normal(t: str) -> str:
    t = t.lower()
    t = re.sub(r"[^\w\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def main():
    if not os.path.isdir(FOLDER):
        print(f"Folder '{FOLDER}' tidak ditemukan.")
        return

    model = WhisperModel(MODEL_UKURAN, device="cpu", compute_type="int8")
    acuan, hasil = [], []

    for nama in sorted(os.listdir(FOLDER)):
        dasar, ext = os.path.splitext(nama)
        if ext.lower() not in EKSTENSI:
            continue
        txt = os.path.join(FOLDER, dasar + ".txt")
        if not os.path.exists(txt):
            print(f"Lewati {nama}: tidak ada {dasar}.txt")
            continue

        with open(txt, encoding="utf-8") as f:
            benar = normal(f.read())

        segmen, _ = model.transcribe(
            os.path.join(FOLDER, nama),
            language="id",
            beam_size=5,
            initial_prompt=PROMPT,
            condition_on_previous_text=False,
            vad_filter=False,
        )
        tebakan = normal(" ".join(s.text for s in segmen))

        if not benar:
            continue
        wer = jiwer.wer(benar, tebakan)
        print(f"{nama}: WER {wer:.1%}")
        print(f"   benar : {benar}")
        print(f"   model : {tebakan}")
        acuan.append(benar)
        hasil.append(tebakan)

    if not acuan:
        print("Tidak ada pasangan rekaman dan teks yang bisa dinilai.")
        return

    wer_total = jiwer.wer(acuan, hasil)
    print("\n==== RINGKASAN ====")
    print(f"Jumlah rekaman : {len(acuan)}")
    print(f"WER total      : {wer_total:.1%}")
    print(f"Akurasi (1-WER): {max(0.0, 1 - wer_total):.1%}")


if __name__ == "__main__":
    main()