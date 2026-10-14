import re
import json
from pathlib import Path


def remove_comments(text):
    # Remove /* ... */ comments
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    # Remove // comments
    text = re.sub(r"//.*", "", text)
    return text


# All blocks "keyword ( name ) { ... }" of a text. Returns [(name, text between the braces)]. The braces are counted, so nested #
# blocks stay inside their parent.                                                                                              #
def find_blocks(text, keyword):
    pattern = re.compile(rf"\b{keyword}\s*\(\s*([^)]+?)\s*\)\s*\{{")
    results = []

    for match in pattern.finditer(text):
        name = match.group(1).strip()
        start = match.end()

        brace_count = 1
        i = start

        while i < len(text) and brace_count > 0:
            if text[i] == "{":
                brace_count += 1
            elif text[i] == "}":
                brace_count -= 1
            i += 1

        block = text[start:i - 1]
        results.append((name, block))

    return results


# Capacitance of a pin block: the "capacitance" value, else "max_capacitance" (output pins). None if the pin has neither. #
def extract_cap(pin_block):
    m = re.search(r"\bcapacitance\s*:\s*([0-9eE+.\-]+)\s*;", pin_block)
    if m:
        return float(m.group(1))

    m = re.search(r"\bmax_capacitance\s*:\s*([0-9eE+.\-]+)\s*;", pin_block)
    if m:
        return float(m.group(1))

    return None


# Read the liberty file and write {cell name: {pin name: capacitance}} as JSON. #
def parse_lib(lib_file, output_json):
    text = Path(lib_file).read_text()
    text = remove_comments(text)

    final_data = {}

    cells = find_blocks(text, "cell")

    for cell_name, cell_block in cells:
        final_data[cell_name] = {}

        pins = find_blocks(cell_block, "pin")

        for pin_name, pin_block in pins:
            cap = extract_cap(pin_block)
            final_data[cell_name][pin_name] = cap

    with open(output_json, "w") as f:
        json.dump(final_data, f, indent=4)

    print(f"INFO: Wrote {output_json}")


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="Extract the input-pin capacitances of a liberty file into a JSON "
                                             "(data/configs/ng45_pin_capacitance.json for NanGate45).")
    ap.add_argument("--lib", required=True, help="liberty file, e.g. NangateOpenCellLibrary_typical.lib")
    ap.add_argument("--out", required=True, help="output JSON")
    a = ap.parse_args()
    parse_lib(a.lib, a.out)