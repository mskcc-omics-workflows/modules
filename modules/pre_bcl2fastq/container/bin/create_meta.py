#!/usr/bin/env python
import sys
from optparse import OptionParser
import xml.etree.ElementTree as ET
from samplesheet import SampleSheet
from exceptions import PreBcl2FastqError, RunInfoError, RunParamsError


class RunInfoXml:

    def __init__(self, run_info_file):
        self.run_info_file = run_info_file
        self.run_name = ''
        self.flowcell = ''
        self.instrument = ''
        self.lane_count = ''
        self.tile_count = ''
        self.base_mask = ''
        self.run_cycle = ''
        self.retrieve_runInfo()

    def retrieve_runInfo(self):
        base_mask = ''
        run_cycle = ''
        try:
            tree = ET.parse(self.run_info_file)
            root = tree.getroot()
        except Exception as e:
            print(RunInfoError(f"Unable to pase run info, error: {e}"))
            return
        for branch in list(root.iter()):
            if branch.tag == "Run":
                self.run_name = branch.attrib["Id"]
            elif branch.tag == "Flowcell":
                self.flowcell = branch.text
            elif branch.tag == "Instrument":
                self.instrument = branch.text
            elif branch.tag == "Read":
                base_mask += branch.attrib["IsIndexedRead"] + \
                    branch.attrib["NumCycles"] + ","
                run_cycle += "{}({}) X ".format(
                    branch.attrib["NumCycles"], branch.attrib["IsIndexedRead"])
            elif branch.tag == "FlowcellLayout":
                self.lane_count = branch.attrib["LaneCount"]
                self.tile_count = branch.attrib["TileCount"]
        self.base_mask = base_mask.replace("Y", "i").replace("N", "y")[:-1]
        self.run_cycle = run_cycle.replace("(N)", "").replace("Y", "I")[:-3]


class RunParamsXML:

    def __init__(self, run_params_file):
        self.run_params_file = run_params_file
        self.rta_version = ''
        self.user = ''
        self.exp_name = ''
        self.run = ''
        self.retrieve_run_params()

    def retrieve_run_params(self):
        try:
            tree = ET.parse(self.run_params_file)
            root = tree.getroot()
        except Exception as e:
            print(RunParamsError(f"Unable to parse run parameter, error: {e}"))
            return
        require_list = ["RTAVersion", "RtaVersion"]
        for item in require_list:
            for rta in root.iter(item):
                self.rta_version = rta.text
        for user in root.iter("Username"):
            if user.text != None:
                self.user = user.text
        for ex in root.iter("ExperimentName"):
            if ex.text != None:
                self.exp_name = ex.text
                self.run = ex.text


def write_file(output: dict, outfile: str):
    header = ""
    row = ""
    with open(outfile, 'w') as f:
        for key, val in output.items():
            header += key + ","
            row += val.replace(",", ";") + ","
        f.write(f"{header[:-1]}\n{row[:-1]}\n")


def main(runinfo, runparams, samplesheet, outfile):
    try:
        output = RunInfoXml(runinfo).__dict__
        output.update(RunParamsXML(runparams).__dict__)
        output.update(SampleSheet(samplesheet).__dict__)
        write_file(output, outfile)
    except Exception as e:
        raise PreBcl2FastqError(f"Unable to parse metadata, error: {e}")


if __name__ == "__main__":
    parser = OptionParser(version="Version 1.0")
    parser.add_option("-i", "--runinfo",
                      dest="runinfo",
                      help="Full path of runinfo.xml")
    parser.add_option("-r", "--runparams",
                      dest="runparams",
                      help="Full path of runparameter.xml")
    parser.add_option("-s", "--samplesheet",
                      dest="samplesheet",
                      help="Full path of SampleSheet.csv")
    parser.add_option("-o", "--outputfile",
                      dest="outfile",
                      help="Full path of output file")
    (opts, args) = parser.parse_args()

    runinfo = opts.runinfo
    runparams = opts.runparams
    samplesheet = opts.samplesheet
    outfile = opts.outfile
    if not outfile:
        outfile = "meta.csv"
    if not outfile.endswith(".csv"):
        outfile = outfile + ".csv"

    sys.exit(main(runinfo, runparams, samplesheet, outfile))
