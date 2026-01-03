import json
import subprocess
import re
import sys

REPO_OWNER = "ehdwns0814"
REPO_NAME = "issue-Automation-Unwind"

def run_command(cmd):
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}", file=sys.stderr)
        return "[]"

def extract_yaml_value(body, key):
    # Try to find yaml block
    yaml_block = re.search(r'```yaml\n(.*?)\n```', body, re.DOTALL)
    if yaml_block:
        content = yaml_block.group(1)
        # Simple regex for key: value or key: [list]
        # For dependencies: ["ID1", "ID2"]
        pattern = f'{key}:\\s*\\[(.*?)\\]'
        match = re.search(pattern, content)
        if match:
            deps_str = match.group(1)
            return [d.strip().strip('"\'') for d in deps_str.split(',') if d.strip()]
        
        # Check for task_id: "VALUE"
        if key == "task_id":
            match = re.search(r'task_id:\s*["\']?([^"\']+)["\']?', content)
            if match:
                return match.group(1)
    return None

def main():
    print("Fetching all open issues...")
    # Fetch issues
    cmd = f"gh issue list --repo {REPO_OWNER}/{REPO_NAME} --state open --json number,title,body --limit 1000"
    issues = json.loads(run_command(cmd))

    print(f"Analyzing {len(issues)} issues...\n")

    # 1. Build Map: Task ID -> Issue Number
    task_id_map = {}
    issue_data = {}

    for issue in issues:
        number = issue['number']
        body = issue['body']
        
        task_id = extract_yaml_value(body, "task_id")
        if not task_id:
            # Fallback: Use issue number as ID if task_id not found
            task_id = f"ISSUE-{number}"
        
        task_id_map[task_id] = number
        
        deps = extract_yaml_value(body, "dependencies") or []
        
        issue_data[task_id] = {
            "number": number,
            "title": issue['title'],
            "dependencies": deps,
            "status": "Open" # Since we queried open issues
        }

    # 2. Check Dependencies
    print("--- Dependency Analysis ---\n")
    
    sorted_tasks = sorted(issue_data.keys(), key=lambda x: issue_data[x]['number'])
    
    has_issues = False

    for task_id in sorted_tasks:
        data = issue_data[task_id]
        deps = data['dependencies']
        
        if not deps:
            continue

        missing_deps = []
        resolved_deps = []

        for dep in deps:
            if dep in task_id_map:
                resolved_deps.append(f"#{task_id_map[dep]} ({dep})")
            else:
                # Check if it might be closed (we only fetched open)
                # Ideally we fetch closed too, but for now mark as unknown/missing
                missing_deps.append(dep)

        if missing_deps:
            has_issues = True
            print(f"[Warning] #{data['number']} {task_id} has MISSING dependencies:")
            for md in missing_deps:
                print(f"  - {md} (Not found in open issues)")
        
        if resolved_deps:
            print(f"#{data['number']} {task_id} depends on:")
            for rd in resolved_deps:
                print(f"  -> {rd}")
            print("")

    if not has_issues:
        print("No missing dependencies found among open issues.")

    # 3. List Independent Tasks (Ready to Start)
    print("\n--- Independent Tasks (Ready to Start) ---")
    print("Tasks with NO dependencies or dependencies are already closed/missing:")
    
    count = 0
    for task_id in sorted_tasks:
        data = issue_data[task_id]
        deps = data['dependencies']
        
        # Check if all deps are resolved (exist in map? or assume satisfied if not in open list?)
        # Let's assume if dep is NOT in open list, it is completed.
        # But we previously checked "missing".
        
        # For "Ready to Start", we want tasks where deps are []
        if not deps:
            print(f"#{data['number']:<4} {data['title']}")
            count += 1
            if count >= 20:
                print("... (and more)")
                break

if __name__ == "__main__":
    main()

