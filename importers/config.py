import os
import sys

# beancount doesn't run from this directory
sys.path.append(os.path.dirname(__file__))

# importers located in the importers directory
from pncbank import PNCBankImporter, PNCBankStatementImporter

CONFIG = [
    PNCBankImporter('Assets:US:PNCBank:Checking', '/importers/accounts.yaml'),
    PNCBankStatementImporter('Assets:US:PNCBank:Checking', '/importers/accounts.yaml'),
]
