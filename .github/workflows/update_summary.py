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
        existing = sections["Modules"]

        parent_header = f"* [{parent}](modules/{parent}/README.md)" if parent else None
        child_entry = f"  {entry}" if parent else entry

        parent_exists = parent and any(line.strip() == parent_header for line in existing)
        child_exists = any(line.strip() == child_entry.strip() for line in existing)

        if child_exists:
            return sections

        new_list = []
        if parent:
            inserted = False
            for line in existing:
                new_list.append(line)
                if not inserted and line.strip() == parent_header:
                    new_list.append(child_entry)
                    inserted = True
            if not parent_exists:
                new_list.append(parent_header)
                new_list.append(child_entry)
        else:
            new_list = existing + [entry]

        sections["Modules"] = new_list

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
