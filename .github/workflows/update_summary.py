import sys
from collections import defaultdict


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
    new_list = []
    found = False
    if feature_type == "module":
        # Check if the new feature is already in current summary file
        if new_feature.replace("\\", "") in [line.strip().replace("\\", "") for line in sections["Modules"]]:
            return sections
        # Get module name from [] and remove the _ part.
        # Check if the first part of the module name exists
        new_feature_category = new_feature.split("]")[0].split("_")[0].replace("* [", "").replace("\\", "").strip()
        for line in sections["Modules"]:
            new_list.append(line)
            if f"[{new_feature_category}]" in line:
                found = True
                new_list.append(f"  {new_feature}\n")
        if not found:
            # If not found, put the new feature to the last
            new_list.append(new_feature + "\n\n")
        sections["Modules"] = new_list

    if feature_type == "subworkflow" and new_feature not in sections["Subworkflows"]:
        # There is no subset of subworkflow, so put the new feature to the last
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
