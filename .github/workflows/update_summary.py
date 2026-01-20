import sys
from collections import defaultdict

def build_module_entry(module_id: str):
    if "/" in module_id:
        namespace, name = module_id.split("/", 1)
        display = f"{namespace}_{name}"
        path = f"modules/{namespace}/{namespace}_{name}.md"
        parent = namespace
    else:
        display = module_id
        path = f"modules/{module_id}.md"
        parent = None
    entry = f"* [{display}]({path})"
    return entry, parent

def load_summary_file(origin: str):
    sections = defaultdict(list)
    current_section = None
    with open(origin, "r") as f:
        for row in f:
            if row.startswith("#"):
                current_section = row.replace("#", "").strip()
                continue
            if row.strip():
                sections[current_section].append(row.rstrip("\n"))
    return sections

def add_new_feature(sections: dict, new_feature: str, feature_type: str):
    if feature_type == "module":
        entry, parent = build_module_entry(new_feature)
        module_lines = sections["Modules"]

        # Check if entry already exists
        existing_entries = [line.strip() for line in module_lines]
        if entry in existing_entries or f"  {entry}" in existing_entries:
            return sections

        if parent:
            # Check if parent already exists
            parent_line = f"* [{parent}](modules/{parent}/README.md)"
            parent_indices = [i for i, line in enumerate(module_lines) if line.strip() == parent_line]
            if parent_indices:
                # Insert under existing parent
                index = parent_indices[-1] + 1
                module_lines.insert(index, f"  {entry}")
            else:
                # Add parent at end if missing, then child
                module_lines.append(parent_line)
                module_lines.append(f"  {entry}")
        else:
            module_lines.append(entry)

        sections["Modules"] = module_lines

    elif feature_type == "subworkflow":
        if new_feature not in sections["Subworkflows"]:
            sections["Subworkflows"].append(new_feature)
    return sections

def rebuild_summary(origin: str, new_feature: str, feature_type: str):
    sections = load_summary_file(origin)
    sections = add_new_feature(sections, new_feature, feature_type)

    out_summary = "# Table of contents\n\n"
    for line in sections["Table of contents"]:
        out_summary += f"{line}\n"
    out_summary += "\n## Modules\n\n"
    for line in sections["Modules"]:
        out_summary += f"{line}\n"
    out_summary += "\n## Subworkflows\n\n"
    for line in sections["Subworkflows"]:
        out_summary += f"{line}\n"
    return out_summary

if __name__ == "__main__":
    origin_summary = sys.argv[1]
    new_feature = sys.argv[2]
    feature_type = sys.argv[3]
    print(rebuild_summary(origin_summary, new_feature, feature_type))
