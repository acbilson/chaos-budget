#!/usr/bin/python3
import os
import re
import csv
from dateutil.parser import parse
from beancount.ingest import importer
from beancount.core import amount
from beancount.core import data
from beancount.core import flags
from beancount.core.number import D


class PNCBankImporter(importer.ImporterProtocol):
    def __init__(self, account):
        self.account = account

    def name(self):
        return('PNCBankImporter')

    def identify(self, f):
        if re.match('pnc*.csv', os.path.basename(f.name)):
            return True
        else:
            return False

    def extract(self, fi):
        entries = []

        with open(fi.name, 'r') as f:
            for index, row in enumerate(csv.DictReader(f)):
                # skips the header
                if index == 0:
                    continue
                meta = data.new_metadata(f.name, index)
                trans_date = parse(row['Date']).date()
                trans_desc = row['Description']
                trans_amt = row['Withdrawals'] + row['Deposits']

                txn = data.Transaction(
                    meta=meta,
                    date=trans_date,
                    flag=flags.FLAG_OKAY,
                    payee=trans_desc,
                    narration="",
                    tags=set(),
                    links=set(),
                    postings=[],
                )

                txn.postings.append(
                    data.Posting(self.account, amount.Amount(D(trans_amt[1:]), 'USD'),
                        None, None, None, None
                    )
                )

                entries.append(txn)
        return entries
