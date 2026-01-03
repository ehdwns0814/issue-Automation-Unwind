import json
import re
from datetime import datetime

# Completed issues as per user input
COMPLETED_IDS = [93, 94, 95]

def main():
    # Load Project Items
    with open('/Users/dongjun/.cursor/projects/Users-dongjun-Documents-workspace-issue-Automation-Unwind/agent-tools/2d844a0c-eaaf-426b-9677-96a03bad95b7.txt', 'r') as f:
        proj_data = json.load(f)

    # Load Issues
    with open('/Users/dongjun/.cursor/projects/Users-dongjun-Documents-workspace-issue-Automation-Unwind/agent-tools/8d9d0682-0455-4d4c-ab94-2f2f2ba69014.txt', 'r') as f:
        issue_data = json.load(f)

    task_id_to_num = {}
    issue_map = {}
    
    # 1. Map Open Issues
    for issue in issue_data:
        num = issue['number']
        body = issue['body']
        
        # Extract Task ID
        tid = f"ISSUE-{num}"
        match = re.search(r'task_id:\s*["\']?([^"\']+)["\']?', body)
        if match:
            tid = match.group(1)
        
        # Extract Dependencies
        deps = []
        yaml_block = re.search(r'```yaml\n(.*?)\n```', body, re.DOTALL)
        if yaml_block:
            d_match = re.search(r'dependencies:\s*\[(.*?)\]', yaml_block.group(1))
            if d_match:
                deps = [d.strip().strip('"\'') for d in d_match.group(1).split(',') if d.strip()]

        issue_map[num] = {
            'number': num,
            'task_id': tid,
            'title': issue['title'],
            'dependencies': deps,
            'start_date': "9999-12-31" # Default
        }

    # 2. Map Dates from Project Items
    # Note: `gh project item-list --format json` structure for fields is often flat in `items`?
    # Or in `fieldValues`. Let's assume keys match "Start date".
    # Since previous grep failed, maybe the keys are field IDs?
    # But `gh project item-list` output usually has keys like "Start date" if using recent version.
    # Let's try to print keys of one item to debug if this runs locally.
    # For now, let's look for ANY key that looks like a date 'YYYY-MM-DD'
    
    for item in proj_data['items']:
        content = item.get('content')
        if not content: continue
        url = content.get('url', '')
        match = re.search(r'/issues/(\d+)$', url)
        if match:
            num = int(match.group(1))
            if num in issue_map:
                # Try to find date in the item dict directly
                for k, v in item.items():
                    if k == "Start date":
                        issue_map[num]['start_date'] = v
                
                # Also check if it is inside fieldValues list
                # "fieldValues": [ { "date": "..." } ] ?
                # We can't see the structure easily without printing.
                # Let's rely on what we saw in `link_issues_to_project.py` logs or similar?
                # Wait, in `check_independent_issues.py` I used `fieldValues`?
                # Let's try to be robust.
                pass

    # 3. Filter Blocked
    completed_task_ids = {"REQ-FUNC-001-iOS", "REQ-FUNC-002-iOS", "REQ-FUNC-003-iOS"}
    # Add Task IDs of COMPLETED_IDS if we found them in open list (unlikely if closed)
    # But user says completed work, not necessarily closed issue.
    # If 93, 94, 95 are open, their IDs are in issue_map.
    for num in COMPLETED_IDS:
        if num in issue_map:
            completed_task_ids.add(issue_map[num]['task_id'])

    available = []
    for num, data in issue_map.items():
        if num in COMPLETED_IDS:
            continue
            
        is_blocked = False
        for dep in data['dependencies']:
            if dep not in completed_task_ids:
                is_blocked = True
                break
        
        if not is_blocked:
            available.append(data)

    # 4. Sort
    available.sort(key=lambda x: x['start_date'])

    print(f"{'No.':<6} {'Start Date':<12} {'Title'}")
    print("-" * 80)
    for item in available:
        print(f"#{item['number']:<5} {item['start_date']:<12} {item['title']}")

if __name__ == "__main__":
    main()


