# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is primarily the content repository for a university-level Flutter/Dart course ("Курс по Flutter"): most work here is authoring/editing course materials in Markdown (and one master `.docx`). The only code lives in the folders listed under "Code in this repository" below.

## Structure

Each `Лекция N - <topic>` folder is one lecture and contains up to three files, all in Russian:

- `лекция.md` — the lecture content/theory
- `вопросы.md` — review questions for students
- `задание.md` — the hands-on assignment for that lecture

`Flutter курс.docx` is a master document that appears to be the source the per-lecture Markdown files were split from.

### Numbering

Folder numbers (`Лекция N - ...`) match the numbering used inside the files — the title in `лекция.md`, the review-questions header in `вопросы.md`, and the assignment number in `задание.md` all agree with the folder number. When renumbering a lecture (moving it earlier/later in the sequence), update the folder name, all in-file headers, and any cross-references to it elsewhere (e.g. "из Задания N", "в Лекции N") to keep everything consistent.

### The CineTrack thread

Starting around folder 5, `задание.md` files are not standalone exercises — they are sequential steps building a single running app called **CineTrack** (a movie-tracking app). Each assignment's "Контекст" section explicitly continues from the previous one (e.g. widgets → navigation → Provider-based state → HTTP → BLoC → persistence → clean architecture). When editing or writing a `задание.md`, check the neighboring lecture folders (by internal numbering, not folder numbering) to keep the CineTrack storyline consistent — introducing a feature/dependency earlier than the lecture that teaches it will break the sequence.

### Code in this repository

Besides the course materials, the repo holds code that is *not* part of any lecture:

- `cine_track/` — the reference CineTrack app, one branch per lecture (`lesson_N`), not on `main`.
- `cine_track_api/` — TMDB-compatible server (Payload CMS 3 + Postgres, pnpm) so students don't have to register on themoviedb.org. The API contract is `API.md` at the repo root.
- `cine_track_web/` — nginx image serving the Flutter web build of `cine_track` (branch `lesson_21`).
- `deploy.sh` (build and push images: `./deploy.sh api|web`) and `portainer-stack.yml` (server stack).

### Duplicate `*_ter_conflict__<timestamp>.md` / `.docx` files

Many files have a sibling named `<name>_ter_conflict__<timestamp>.<ext>` with identical content — these are sync-conflict artifacts (Google Drive), not intentional alternate versions. Edit the canonical file (without the suffix); don't propagate edits into the conflict copies, and flag to the user rather than silently deleting them if cleanup seems warranted.
