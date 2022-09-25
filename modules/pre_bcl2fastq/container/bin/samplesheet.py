import csv
from collections import defaultdict
from exceptions import SampleSheetError

assay_config = {
    "IMPACT": {"mismatch": "0", "option": ""},
    "ARCHER": {"mismatch": "1", "option": ""},
    "ACCESS": {"mismatch": "1", "option": "--no-lane-splitting"},
    "LIQUIDPLEX": {"mismatch": "1", "option": "--no-lane-splitting"},
    "OTHER": {"mismatch": "1", "option": ""},
}

assay_map = {
    "ArcherPanHeme": "Archer",
    "IMPACTH": "IMPACT",
    "ACCESSH": "ACCESS",
    "ACCESSL": "ACCESS",
}


class SampleSheet:

    def __init__(self, samplesheet):
        self.samplesheet = samplesheet
        self.sample2project = ""
        self.assay = ""
        self.mismatch = "1"
        self.no_lane_split = ""
        self.get_info()

    def load_sample_sheet(self):
        sections = defaultdict(list)
        current_section = None
        with open(self.samplesheet, "r") as file_read:
            for row in file_read:
                if row.startswith("["):
                    current_section = row.split(",")[0].strip()
                    continue
                if not row.startswith("#"):
                    sections[current_section].append(row)
        return sections["[Data]"]

    def get_records(self):
        data_sec = self.load_sample_sheet()
        ss_records = list(csv.DictReader(data_sec, delimiter=","))
        return ss_records

    def get_info(self):
        try:
            ss_records = self.get_records()
        except Exception as e:
            raise SampleSheetError(f"Unable to parse samplesheet, error: {e}")
        sample2project = set()
        assay = set()
        for rec in ss_records:
            sample2project.add(f'{rec["Sample_ID"]}:{rec["Sample_Project"]}')
            assay_type = rec["Sample_Project"].split("V")[0].split("v")[0]
            if assay_type in assay_map:
                assay_type = assay_map[assay_type]
            assay.add(assay_type)
        self.sample2project += ";".join(list(sample2project))
        if len(assay) > 1:
            raise SampleSheetError(f"Unrecognized assay type: {assay}")
        self.assay += ";".join(list(assay))

        # mismatch and lane splitting
        if self.assay.upper() in assay_config:
            self.mismatch = assay_config[self.assay.upper()]["mismatch"]
            self.no_lane_split = assay_config[self.assay.upper()]["option"]
