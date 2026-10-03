#!/usr/bin/env python3
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[2]
source=(root/"Alphabetical List Utility/ALUDataManager.m").read_text()
start=source.index("- (void)generatePlaygroundIconIfNeededForCompanyName:")
end=source.index("- (BOOL)useWebIconForListTitle:",start)
methods=source[start:end]
harness=(Path(__file__).parent/"main.m").read_text().replace("// PRODUCTION_METHODS",methods)
with tempfile.TemporaryDirectory(prefix="atoz-icon-queue-") as d:
    d=Path(d);p=d/"main.m";p.write_text(harness)
    subprocess.run(["xcrun","clang","-fobjc-arc","-fblocks","-framework","Foundation",str(p),"-o",str(d/"check")],check=True)
    subprocess.run([str(d/"check")],check=True)
