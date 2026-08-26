# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is **not a software project** — it is the content repository for a university-level Flutter/Dart course ("Курс по Flutter"). There is no code to build, lint, or test. All work here is authoring/editing course materials in Markdown (and one master `.docx`).

## Structure

Each `Лекция N - <topic>` folder is one lecture and contains up to three files, all in Russian:

- `лекция.md` — the lecture content/theory
- `вопросы.md` — review questions for students
- `задание.md` — the hands-on assignment for that lecture

`Flutter курс.docx` is a master document that appears to be the source the per-lecture Markdown files were split from.

### Numbering mismatch

Folder numbers (`Лекция N - ...`) do **not** match the numbering used inside the files. Folders 1–4 cover Dart fundamentals and environment setup; starting from folder 5, the internal title in `лекция.md` and the assignment number in `задание.md` both run 3 lower than the folder number (e.g. folder `Лекция 7 - Основы компоновки UI` contains `# Лекция 4 - ...` and `# Задание 4 — ...`; folder `Лекция 12` contains `# Лекция 9 - ...` / `# Задание 9 - ...`). When asked to edit "Лекция N", confirm whether N refers to the folder name or the in-document number.

### The CineTrack thread

Starting around folder 5, `задание.md` files are not standalone exercises — they are sequential steps building a single running app called **CineTrack** (a movie-tracking app). Each assignment's "Контекст" section explicitly continues from the previous one (e.g. widgets → navigation → Provider-based state → HTTP → BLoC → persistence → clean architecture). When editing or writing a `задание.md`, check the neighboring lecture folders (by internal numbering, not folder numbering) to keep the CineTrack storyline consistent — introducing a feature/dependency earlier than the lecture that teaches it will break the sequence.

### Duplicate `*_ter_conflict__<timestamp>.md` / `.docx` files

Many files have a sibling named `<name>_ter_conflict__<timestamp>.<ext>` with identical content — these are sync-conflict artifacts (Google Drive), not intentional alternate versions. Edit the canonical file (without the suffix); don't propagate edits into the conflict copies, and flag to the user rather than silently deleting them if cleanup seems warranted.
