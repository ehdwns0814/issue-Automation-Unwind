import json
import subprocess
import re
from datetime import datetime

REPO_OWNER = "ehdwns0814"
REPO_NAME = "issue-Automation-Unwind"
PROJECT_NUMBER = 8
TARGET_TASK_ID = "REQ-FUNC-002-iOS" # ID of Issue #94
TARGET_ISSUE_NUM = 94

def run_command(cmd):
    result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
    return result.stdout

def get_task_id_from_body(body):
    match = re.search(r'task_id:\s*"([^"]+)"', body)
    if match:
        return match.group(1)
    # Fallback to REQ-ID from title if needed, or parse simple yaml
    return None

def get_dependencies_from_body(body):
    # regex for dependencies: ["A", "B"] or [A, B]
    match = re.search(r'dependencies:\s*\[(.*?)\]', body)
    if match:
        content = match.group(1)
        # Split by comma and strip quotes
        deps = [d.strip().strip('"\'') for d in content.split(',')]
        return [d for d in deps if d]
    return []

def main():
    print(f"Fetching project items for Project #{PROJECT_NUMBER}...")
    # Get Project Items (for Dates)
    cmd_proj = f"gh project item-list {PROJECT_NUMBER} --owner {REPO_OWNER} --format json --limit 1000"
    proj_data = json.loads(run_command(cmd_proj))
    
    # Map URL -> {startDate, targetDate}
    proj_map = {}
    for item in proj_data['items']:
        content = item.get('content')
        if not content: continue
        url = content.get('url')
        
        start_date = item.get('fieldValues', {}).get(u'Start date', None) # Note: field names might differ in JSON output
        # Let's inspect the JSON structure if needed, but usually it's keyed by field name or id
        # 'gh project item-list --format json' returns fields in a specific way.
        
        # Actually the keys in 'fieldValues' are usually the field NAMES if using recent gh cli? 
        # Let's check keys carefully. The standard output has keys as names.
        
        # Normalize date
        s_date = item.get('Start date') # Sometimes it's direct property? No, it's in fieldValues.
        # Let's try to look for the field name "Start date" in the list of fields.
        
        # In JSON output from gh project item-list:
        # fields are usually inside the item object or we have to look up.
        # Wait, the output format of `gh project item-list` is list of items.
        # Let's assume we can match by issue URL.
        
        proj_map[url] = item

    print("Fetching open issues...")
    # Get Issues (for Body/Dependencies)
    cmd_issues = f"gh issue list --repo {REPO_OWNER}/{REPO_NAME} --state open --json number,title,body,url --limit 1000"
    issues = json.loads(run_command(cmd_issues))

    available_issues = []

    for issue in issues:
        num = issue['number']
        if num == TARGET_ISSUE_NUM:
            continue

        body = issue['body']
        deps = get_dependencies_from_body(body)
        
        # Check if TARGET_TASK_ID is in dependencies
        if TARGET_TASK_ID in deps:
            continue
            
        # Get Start Date from Project Map
        url = issue['url']
        p_item = proj_map.get(url)
        
        start_date_str = "9999-12-31" # Default to end of time if no date
        display_date = "N/A"
        
        if p_item:
            # Find Start date field
            # The structure is usually: { fieldValues: { nodes: [ { field: { name: "Start date" }, date: "..." } ] } } ??
            # Or simplified JSON?
            # Let's rely on finding the field by name in the fields list
            # Actually, `gh project item-list --format json` returns a simplified structure or GraphQL?
            # It returns: { items: [ { content: ..., fieldValues: [ { name: "Start date", value: "2026-01-01" } ] } ] }
            # Let's iterate fieldValues
            
            f_vals = p_item.get('fieldValues', [])
            for fv in f_vals:
                if fv.get('field', {}).get('name') == 'Start date':
                    val = fv.get('date') or fv.get('text') or fv.get('value')
                    if val:
                        start_date_str = val
                        display_date = val
                        break
        
        available_issues.append({
            'number': num,
            'title': issue['title'],
            'start_date': start_date_str,
            'display_date': display_date
        })

    # Sort
    available_issues.sort(key=lambda x: x['start_date'])

    print(f"\n--- Issues independent of #{TARGET_ISSUE_NUM} ({TARGET_TASK_ID}) ---")
    print(f"{'No.':<6} {'Start Date':<12} {'Title'}")
    print("-" * 60)
    for i in available_issues:
        print(f"#{i['number']:<5} {i['display_date']:<12} {i['title']}")

if __name__ == "__main__":
    main()

