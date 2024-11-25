#!/usr/bin/env python3

import argparse

VERSION = 1.0

ACCEPTED_ALLELES = [
    "BoLA-D18.4",
    "BoLA-HD6",
    "BoLA-JSP.1",
    "BoLA-T2C",
    "BoLA-T2a",
    "BoLA-T2b",
    "H-2-Db",
    "H-2-Dd",
    "H-2-Kb",
    "H-2-Kd",
    "H-2-Kk",
    "H-2-Ld",
    "HLA-A01:01",
    "HLA-A02:01",
    "HLA-A02:02",
    "HLA-A02:03",
    "HLA-A02:06",
    "HLA-A02:11",
    "HLA-A02:12",
    "HLA-A02:16",
    "HLA-A02:17",
    "HLA-A02:19",
    "HLA-A02:50",
    "HLA-A03:01",
    "HLA-A11:01",
    "HLA-A23:01",
    "HLA-A24:02",
    "HLA-A24:03",
    "HLA-A25:01",
    "HLA-A26:01",
    "HLA-A26:02",
    "HLA-A26:03",
    "HLA-A29:02",
    "HLA-A30:01",
    "HLA-A30:02",
    "HLA-A31:01",
    "HLA-A32:01",
    "HLA-A32:07",
    "HLA-A32:15",
    "HLA-A33:01",
    "HLA-A66:01",
    "HLA-A68:01",
    "HLA-A68:02",
    "HLA-A68:23",
    "HLA-A69:01",
    "HLA-A80:01",
    "HLA-B07:02",
    "HLA-B08:01",
    "HLA-B08:02",
    "HLA-B08:03",
    "HLA-B14:02",
    "HLA-B15:01",
    "HLA-B15:02",
    "HLA-B15:03",
    "HLA-B15:09",
    "HLA-B15:17",
    "HLA-B18:01",
    "HLA-B27:05",
    "HLA-B27:20",
    "HLA-B35:01",
    "HLA-B35:03",
    "HLA-B38:01",
    "HLA-B39:01",
    "HLA-B40:01",
    "HLA-B40:02",
    "HLA-B40:13",
    "HLA-B42:01",
    "HLA-B44:02",
    "HLA-B44:03",
    "HLA-B45:01",
    "HLA-B46:01",
    "HLA-B48:01",
    "HLA-B51:01",
    "HLA-B53:01",
    "HLA-B54:01",
    "HLA-B57:01",
    "HLA-B58:01",
    "HLA-B73:01",
    "HLA-B83:01",
    "HLA-C03:03",
    "HLA-C04:01",
    "HLA-C05:01",
    "HLA-C06:02",
    "HLA-C07:01",
    "HLA-C07:02",
    "HLA-C08:02",
    "HLA-C12:03",
    "HLA-C14:02",
    "HLA-C15:02",
    "HLA-E01:01",
    "Mamu-A01",
    "Mamu-A02",
    "Mamu-A07",
    "Mamu-A11",
    "Mamu-A20102",
    "Mamu-A2201",
    "Mamu-A2601",
    "Mamu-A70103",
    "Mamu-B01",
    "Mamu-B03",
    "Mamu-B08",
    "Mamu-B1001",
    "Mamu-B17",
    "Mamu-B3901",
    "Mamu-B52",
    "Mamu-B6601",
    "Mamu-B8301",
    "Mamu-B8701",
    "Patr-A0101",
    "Patr-A0301",
    "Patr-A0401",
    "Patr-A0701",
    "Patr-A0901",
    "Patr-B0101",
    "Patr-B1301",
    "Patr-B2401",
    "SLA-10401",
    "SLA-20401",
    "SLA-30401",
]


def trim_hla(hla_string):
    rejected_list = []
    accepted_list = []
    hla_alleles = hla_string.split(",")
    for single_hla_allele in hla_alleles:
        if single_hla_allele not in ACCEPTED_ALLELES:
            rejected_list.append(single_hla_allele)
        else:
            accepted_list.append(single_hla_allele)
    with open("hla_accepted.txt", "w") as accepted_file:
        accepted_hlas = "\n".join(accepted_list)
        accepted_file.write(accepted_hlas)
    with open("hla_rejected.txt", "w") as rejected_file:
        rejected_hlas = "\n".join(rejected_list)
        rejected_file.write(rejected_hlas)
    accepted_output = ",".join(accepted_list)
    print(accepted_output)


def main():
    parser = argparse.ArgumentParser(description="Only accept HLA alleles that are accepted by netmhc 3.4")
    parser.add_argument("--hla", help="Hla allele string")
    parser.add_argument("-v", "--version", action="version", version="v{}".format(VERSION))
    args = parser.parse_args()
    trim_hla(args.hla)


if __name__ == "__main__":
    main()
