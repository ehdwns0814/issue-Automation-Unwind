import json
import re
from datetime import datetime

# Completed issues as per user input
COMPLETED_IDS = [93, 94, 95]

def extract_dependencies(body):
    # Match dependencies: ["ID1", "ID2"] or [ID1, ID2]
    # Also map Task IDs to Issue Numbers if possible, but here we might need a mapping.
    # For now, let's look for dependencies in the body.
    
    # We need a map of Task ID -> Issue Number first.
    pass

def get_task_id(body, number):
    match = re.search(r'task_id:\s*["\']?([^"\']+)["\']?', body)
    if match:
        return match.group(1)
    return f"ISSUE-{number}"

def parse_dates(date_str):
    if not date_str: return "9999-12-31"
    return date_str

def main():
    # Load Project Items (for Dates)
    with open('/Users/dongjun/.cursor/projects/Users-dongjun-Documents-workspace-issue-Automation-Unwind/agent-tools/25a4af26-894e-4e8f-85fd-3f4b33f284b9.txt', 'r') as f:
        proj_data = json.load(f)

    # Load Issues (for Dependencies)
    with open('/Users/dongjun/.cursor/projects/Users-dongjun-Documents-workspace-issue-Automation-Unwind/agent-tools/8d9d0682-0455-4d4c-ab94-2f2f2ba69014.txt', 'r') as f:
        issue_data = json.load(f)

    # 1. Build Maps
    # Task ID -> Issue Number
    # Issue Number -> { Dependencies (Task IDs), Start Date, Title }
    
    task_id_to_num = {}
    issue_map = {}
    
    # Pre-fill completed ones (we don't have their bodies here if they are closed, but user said 93-95 are done. 
    # Actually we fetched OPEN issues. If 93-95 are still open in GH, they are in issue_data.
    # If user closed them, they are not.
    # But user query implies he "completed work", maybe not closed on GH yet.
    # Let's treat 93, 94, 95 as "Satisfied" regardless of open/closed state.
    
    # We need to find Task IDs for 93, 94, 95 to mark them as resolved dependencies.
    # Let's assume we can scan open issues first.
    
    for issue in issue_data:
        num = issue['number']
        body = issue['body']
        tid = get_task_id(body, num)
        task_id_to_num[tid] = num
        
        # Parse deps
        deps = []
        yaml_block = re.search(r'```yaml\n(.*?)\n```', body, re.DOTALL)
        if yaml_block:
            d_match = re.search(r'dependencies:\s*\[(.*?)\]', yaml_block.group(1))
            if d_match:
                deps = [d.strip().strip('"\'') for d in d_match.group(1).split(',') if d.strip()]
        
        issue_map[num] = {
            'task_id': tid,
            'title': issue['title'],
            'dependencies': deps,
            'start_date': "9999-12-31", # Default
            'url': f"https://github.com/ehdwns0814/issue-Automation-Unwind/issues/{num}"
        }

    # Map Project Dates to Issues
    # Project items have content.url
    for item in proj_data['items']:
        content = item.get('content')
        if not content: continue
        url = content.get('url', '')
        # Extract number from url
        # https://github.com/owner/repo/issues/123
        match = re.search(r'/issues/(\d+)$', url)
        if match:
            num = int(match.group(1))
            if num in issue_map:
                # Find Start date
                # Field values structure
                # In the JSON provided previously:
                # { fieldValues: [ { value: "2026-01-02", ... } ] } ? 
                # Actually previously we saw `fieldValues` as a list of nodes or simplified?
                # The output format for `item-list --format json` usually has key-value if fields are simple.
                # Let's check the previous `check_independent_issues.py` output logic or just assume standard keys.
                # If using `gh project item-list --format json`, the fields are directly in the object if typed?
                # No, they are usually in `fieldValues`.
                
                # Let's look for "Start date"
                s_date = None
                for f in item.get('fieldValues', []):
                    # fieldValues is list of objects?
                    # Based on typical output:
                    # "fieldValues": [ { "date": "2026-01-02", "field": { "name": "Start date" } } ]
                    # OR simplified: "Start date": "2026-01-02" if fields are flattened?
                    # The previous output showed `item-list` returns a specific structure.
                    # Let's try to grab any date looking string from fields named "Start date".
                    
                    # Assuming standard GH CLI json output:
                    fname = f.get('field', {}).get('name')
                    if fname == 'Start date':
                        s_date = f.get('date')
                        break
                
                if s_date:
                    issue_map[num]['start_date'] = s_date

    # 2. Determine Available Issues
    available = []
    
    # We treat 93, 94, 95 as COMPLETED.
    # We also need to map their Task IDs.
    # If they are in `issue_data` (open), we have their IDs.
    # If they are closed (not in `issue_data`), we might miss their IDs if we rely only on open issues.
    # BUT, dependencies are strings. We need to know if a dependency string resolves to a COMPLETED issue.
    
    # Let's try to infer Task IDs for 93, 94, 95 if they are open.
    completed_task_ids = set()
    for num in COMPLETED_IDS:
        if num in issue_map:
            completed_task_ids.add(issue_map[num]['task_id'])
        else:
            # If not in open list, maybe we can guess or it's not needed if no one depends on it?
            # Or we assume the dependency string in other issues matches.
            # E.g. REQ-FUNC-001-iOS is likely #93.
            pass
            
    # Hardcode known mapping from previous context if needed
    # #93 -> REQ-FUNC-001-iOS
    # #94 -> REQ-FUNC-002-iOS
    # #95 -> REQ-FUNC-003-iOS
    completed_task_ids.add("REQ-FUNC-001-iOS")
    completed_task_ids.add("REQ-FUNC-002-iOS")
    completed_task_ids.add("REQ-FUNC-003-iOS")
    completed_task_ids.add("REQ-FUNC-001") # Just in case

    print(f"Assumed Completed Task IDs: {completed_task_ids}\n")

    for num, data in issue_map.items():
        if num in COMPLETED_IDS:
            continue
            
        deps = data['dependencies']
        is_blocked = False
        
        for dep in deps:
            # Check if dep is in completed_task_ids
            if dep not in completed_task_ids:
                # Dependency NOT completed
                # Check if dependency is actually another issue that is NOT completed
                # If dependency is external or unknown, we might warn, but here we assume blocked.
                is_blocked = True
                break
        
        if not is_blocked:
            available.append(data)

    # 3. Sort by Start Date
    available.sort(key=lambda x: x['start_date'])

    # 4. Output
    print(f"{'No.':<6} {'Start Date':<12} {'Title'}")
    print("-" * 80)
    for item in available:
        # Find number from issue_map (reverse lookup or store in item)
        # item is the value dict, we need the key (number)
        # Let's store number in data
        # We can find it by iterating issue_map again or just add it above.
        # Reworking loop slightly to add number.
        pass

    # Quick fix for print
    for num, data in issue_map.items():
        data['number'] = num
        
    # Re-sort
    available_with_num = [d for n, d in issue_map.items() if n not in COMPLETED_IDS]
    # Re-filter blocked
    final_list = []
    for data in available_with_num:
        deps = data['dependencies']
        is_blocked = False
        for dep in deps:
            if dep not in completed_task_ids:
                is_blocked = True
                break
        if not is_blocked:
            final_list.append(data)
            
    final_list.sort(key=lambda x: x['start_date'])
    
    for item in final_list:
        print(f"#{item['number']:<5} {item['start_date']:<12} {item['title']}")

if __name__ == "__main__":
    main()

