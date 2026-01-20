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
        existing_lines = [line.rstrip("\n") for line in module_lines]

        if entry in existing_lines or f"  {entry}" in existing_lines:
            return sections

        if parent:
            parent_line = f"* [{parent}](modules/{parent}/README.md)"
            parent_present = any(line.strip() == parent_line for line in existing_lines)
            new_module_lines = []
            inserted = False

            for line in module_lines:
                new_module_lines.append(line)
                if parent_present and not inserted and line.strip() == parent_line:
                    new_module_lines.append(f"  {entry}\n")
                    inserted = True

            if not parent_present:
                new_module_lines.append(f"{parent_line}\n")
                new_module_lines.append(f"  {entry}\n")

            sections["Modules"] = new_module_lines

        else:
            module_lines.append(f"{entry}\n")
            sections["Modules"] = module_lines

    elif feature_type == "subworkflow":
        if new_feature + "\n" not in sections["Subworkflows"]:
            sections["Subworkflows"].append(new_feature + "\n")


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
