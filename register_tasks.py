import os
import subprocess
import re
import json
import time

REPO = "ehdwns0814/issue-Automation-Unwind"
PROJECT_NUMBER = 7
PROJECT_ID = "PVT_kwHOBdSnnc4BLsTW"
OWNER = "ehdwns0814"

# Field IDs
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

def ensure_label(label):
    # Try to create label, ignore error if it exists
    run_cmd(["gh", "label", "create", label, "--repo", REPO, "--color", "ededed"])

def process_file(filepath):
    print(f"Processing {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract Title
    title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else os.path.basename(filepath)

    # Extract YAML block
    yaml_match = re.search(r'```yaml\n(.*?)\n```', content, re.DOTALL)
    if not yaml_match:
        return

    yaml_text = yaml_match.group(1)
    
    metadata = {}
    for line in yaml_text.split('\n'):
        if ':' in line:
            parts = line.split(':', 1)
            metadata[parts[0].strip()] = parts[1].strip().strip('"').strip("'")

    # Labels
    labels = ["Issue-Automation"]
    if 'type' in metadata: labels.append(metadata['type'].capitalize())
    if 'epic' in metadata: labels.append(metadata['epic'])
    
    if 'component' in metadata:
        comp_str = metadata['component'].strip('[]')
        comps = [c.strip().strip('"').strip("'") for c in comp_str.split(',')]
        labels.extend(comps)

    # Ensure all labels exist
    for label in labels:
        ensure_label(label)

    # Create Issue
    create_cmd = [
        "gh", "issue", "create",
        "--repo", REPO,
        "--title", title,
        "--body", content,
        "--label", ",".join(set(labels))
    ]
    stdout, stderr, code = run_cmd(create_cmd)
    
    if code != 0:
        print(f"Failed to create issue for {filepath}: {stderr}")
        return

    issue_url = stdout
    print(f"Created Issue: {issue_url}")

    # Add to Project
    add_cmd = [
        "gh", "project", "item-add", str(PROJECT_NUMBER),
        "--owner", OWNER,
        "--url", issue_url,
        "--format", "json"
    ]
    stdout, stderr, code = run_cmd(add_cmd)
    if code != 0:
        print(f"Failed to add to project: {stderr}")
        return

    try:
        item_data = json.loads(stdout)
        item_id = item_data.get("id")
    except:
        item_id = re.search(r'"id":"([^"]+)"', stdout)
        item_id = item_id.group(1) if item_id else None

    if not item_id:
        return

    # Set Fields
    if 'start_date' in metadata and metadata['start_date'] != 'null':
        run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", START_DATE_FIELD, "--value", metadata['start_date'], "--project-id", PROJECT_ID])
    
    if 'due_date' in metadata and metadata['due_date'] != 'null':
        run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", TARGET_DATE_FIELD, "--value", metadata['due_date'], "--project-id", PROJECT_ID])

    if 'priority' in metadata and metadata['priority'] in PRIORITY_MAP:
        run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", PRIORITY_FIELD, "--project-id", PROJECT_ID, "--single-select-option-id", PRIORITY_MAP[metadata['priority']]])

    if 'estimated_effort' in metadata and metadata['estimated_effort'] in SIZE_MAP:
        run_cmd(["gh", "project", "item-edit", "--id", item_id, "--field-id", SIZE_FIELD, "--project-id", PROJECT_ID, "--single-select-option-id", SIZE_MAP[metadata['estimated_effort']]])

def main():
    task_dirs = [
        "tasks/functional/iOS",
        "tasks/functional/Backend",
        "tasks/non-functional"
    ]
    
    for tdir in task_dirs:
        if not os.path.exists(tdir): continue
        for root, dirs, files in os.walk(tdir):
            for file in sorted(files):
                if file.endswith(".md"):
                    process_file(os.path.join(root, file))
                    time.sleep(1) # Avoid secondary rate limits

if __name__ == "__main__":
    main()
