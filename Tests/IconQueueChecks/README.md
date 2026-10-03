# Generated icon queue regression checks

Run `python3 Tests/IconQueueChecks/run.py` on macOS.

The runner compiles the current production `generatePlaygroundIconIfNeededForCompanyName:` and `processPlaygroundQueue` methods directly from `ALUDataManager.m`. Foundation-only adapters replace UIKit image payloads, persistence and the Image Playground provider, so responses can be completed in a controlled order. It does not launch an app, call Image Playground, reset app data or control the computer.

Checks cover two queued notes with web lookups off, a manual icon chosen during generation, a hidden or deleted note, nil responses and continued queue processing. These checks verify callback decisions and queue state; they do not prove actual image rendering, disk persistence or supported-device generation.
