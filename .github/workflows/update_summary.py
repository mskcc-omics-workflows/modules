import sys

def update_summary(origin: str, new_feature: str, feature_type: str):
    out_summary = ""
    with open(origin, 'r') as f:
        for line in f.readlines():
            if feature_type == "module" and line.startswith("## Subworkflows"):
                out_summary += new_feature + '\n\n'
            if line.strip():
                out_summary += line
    if feature_type == "subworkflow":
        out_summary += new_feature
    return out_summary

if __name__ == "__main__":
    origin_summary = sys.argv[1]
    new_feature = sys.argv[2]
    feature_type = sys.argv[3]
    print(update_summary(origin_summary, new_feature, feature_type))
