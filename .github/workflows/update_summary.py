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

def update_summary_old(origin: str, new_feature: str, feature_type: str):
    out_summary = ""
    with open(origin, 'r') as f:
        for line in f.readlines():
            if feature_type == "module" and line.startswith("## Subworkflows") and new_feature not in out_summary:
                out_summary += new_feature + '\n\n'
            if line.strip():
                out_summary += line
    if feature_type == "subworkflow" and new_feature not in out_summary:
        out_summary += new_feature
    return out_summary


def load_summary_file(origin: str):
    # Read the summary file to dict
    # keys, "Table of contents", "Modules", "Subworkflows"
    # values are list of lines
    sections = defaultdict(list)
    current_section = None
    with open(origin, "r") as file_read:
        for row in file_read:
            if row.startswith("#"):
                current_section = row.replace("#", "").strip()
                continue
            if row.strip():
                sections[current_section].append(row)
    return sections


def add_new_feature(sections: dict, new_feature: str, feature_type: str):
    if feature_type == "module":
        entry, parent = build_module_entry(new_feature)
        existing = [line.strip() for line in sections["Modules"]]
        if entry in existing or f"  {entry}" in existing:
            return sections

        new_list = []
        inserted = False

        for line in sections["Modules"]:
            new_list.append(line)
            if parent and not inserted and line.startswith(f"* [{parent}]("):
                new_list.append(f"  {entry}\n")
                inserted = True

        if parent and not inserted:
            new_list.append(f"* [{parent}](modules/{parent}/README.md)\n")
            new_list.append(f"  {entry}\n")

        if not parent:
            new_list.append(entry + "\n")

        sections["Modules"] = new_list

    elif feature_type == "subworkflow":
        if new_feature + "\n" not in sections["Subworkflows"]:
            sections["Subworkflows"].append(new_feature + "\n")

    return sections

def rebuild_summary(origin: str, new_feature: str, feature_type: str):
    # Load current summary file to dictionary
    sections = load_summary_file(origin=origin)
    # Add the new feature to summary file dict
    updated_sections = add_new_feature(
        sections=sections, new_feature=new_feature, feature_type=feature_type)
    # Output the updated summary file to string
    out_summary = "# Table of contents\n\n"
    for line in updated_sections["Table of contents"]:
        out_summary += line
    out_summary += "\n## Modules\n\n"
    for line in updated_sections["Modules"]:
        out_summary += line
    out_summary += "\n## Subworkflows\n\n"
    for line in updated_sections["Subworkflows"]:
        out_summary += line
    return out_summary


if __name__ == "__main__":
    origin_summary = sys.argv[1]
    new_feature = sys.argv[2]
    feature_type = sys.argv[3]
    print(rebuild_summary(origin_summary, new_feature, feature_type))
