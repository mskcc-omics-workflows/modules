
class PreBcl2FastqError(Exception):
    """Base class for all exceptions"""


class RunParamsError(PreBcl2FastqError):
    """Error in parsing data from runparameter.xml"""


class RunInfoError(PreBcl2FastqError):
    """Error in parsing data from runinfo.xml"""


class SampleSheetError(PreBcl2FastqError):
    """Error in parsing data from SampleSheet.csv"""
