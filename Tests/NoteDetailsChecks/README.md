# Note details checks

Run `bash Tests/NoteDetailsChecks/run.sh` on macOS. It compiles the production Foundation/CryptoKit store and intent matcher with isolated temporary fixtures. It checks legacy-date honesty, stable identity across rename/reload, attached file bytes, editable drawing replacement, corrupt-index preservation, failed-write rollback and store recognition/exclusions/opt-out. It does not simulate Core Location, microphone recording or iOS notification delivery. Native field qualification remains separate.
