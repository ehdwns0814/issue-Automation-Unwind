import json
import subprocess
import re

PROJECT_ID = "PVT_kwHOBdSnnc4BLsTW"
START_DATE_FIELD = "PVTF_lAHOBdSnnc4BLsTWzg7MKRs"
TARGET_DATE_FIELD = "PVTF_lAHOBdSnnc4BLsTWzg7MKRw"
PRIORITY_FIELD = "PVTSSF_lAHOBdSnnc4BLsTWzg7MKRg"
SIZE_FIELD = "PVTSSF_lAHOBdSnnc4BLsTWzg7MKRk"

PRIORITY_MAP = {
    "Must": "79628723",
    "Should": "0a877460",
    "Could": "da944a9c"
}

SIZE_MAP = {
    "XS": "6c6483d2",
    "S": "f784b110",
    "M": "7515a9f1",
    "L": "817d0097",
    "XL": "db339eb2"
}

def run_cmd(cmd):
    # print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip(), result.stderr.strip(), result.returncode

def main():
    with open('items.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    for item in data.get('items', []):
        item_id = item.get('id')
        body = item.get('content', {}).get('body', '')
        
        if not body: continue
        
        # Extract YAML block
        yaml_match = re.search(r'```yaml\n(.*?)\n```', body, re.DOTALL)
        if not yaml_match: continue

        yaml_text = yaml_match.group(1)
        metadata = {}
        for line in yaml_text.split('\n'):
            if ':' in line:
                parts = line.split(':', 1)
                metadata[parts[0].strip()] = parts[1].strip().strip('"').strip("'")

        print(f"Updating Item {item_id} (Title: {item.get('title')})...")

        # Set Start Date
        if 'start_date' in metadata and metadata['start_date'] not in ['null', '']:
            run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", START_DATE_FIELD, "--date", metadata['start_date'], "--project-id", PROJECT_ID])
        
        # Set Target Date
        if 'due_date' in metadata and metadata['due_date'] not in ['null', '']:
            run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", TARGET_DATE_FIELD, "--date", metadata['due_date'], "--project-id", PROJECT_ID])

        # Priority (already set correctly? let's ensure)
        if 'priority' in metadata and metadata['priority'] in PRIORITY_MAP:
            run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", PRIORITY_FIELD, "--project-id", PROJECT_ID, "--single-select-option-id", PRIORITY_MAP[metadata['priority']]])

        # Size
        if 'estimated_effort' in metadata and metadata['estimated_effort'] in SIZE_MAP:
            run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", SIZE_FIELD, "--project-id", PROJECT_ID, "--single-select-option-id", SIZE_MAP[metadata['estimated_effort']]])

if __name__ == "__main__":
    main()
